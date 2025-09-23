#!/bin/bash

# Script to update peer nodes by testing existing ones and adding new ones from Polkachu API
# This script runs as part of a GitHub Action to maintain the peer-nodes.txt file

set -e

PEER_NODES_FILE="mainnet/peer-nodes.txt"
API_URL="https://polkachu.com/api/v2/chains/akash/live_peers"
TEMP_FILE=$(mktemp)
ACTIVE_PEERS_FILE=$(mktemp)
NEW_PEERS_FILE=$(mktemp)

# Function to test if a port is open using netcat
test_port() {
    local host=$1
    local port=$2
    local timeout=5
    
    if nc -z -w$timeout "$host" "$port" 2>/dev/null; then
        return 0  # Port is open
    else
        return 1  # Port is closed
    fi
}

# Function to extract host and port from peer string
extract_host_port() {
    local peer=$1
    # Format: node_id@host:port
    # Extract everything after @ and split by :
    local host_port=$(echo "$peer" | sed 's/.*@//')
    local host=$(echo "$host_port" | cut -d: -f1)
    local port=$(echo "$host_port" | cut -d: -f2)
    echo "$host $port"
}

# Function to test existing peer nodes
test_existing_peers() {
    echo "Testing existing peer nodes..."
    local removed_count=0
    
    if [ ! -f "$PEER_NODES_FILE" ]; then
        echo "Warning: $PEER_NODES_FILE not found"
        return
    fi
    
    while IFS= read -r peer; do
        if [ -n "$peer" ]; then
            local host_port=$(extract_host_port "$peer")
            local host=$(echo "$host_port" | cut -d' ' -f1)
            local port=$(echo "$host_port" | cut -d' ' -f2)
            
            echo -n "Testing $peer... "
            if test_port "$host" "$port"; then
                echo "✓ Active"
                echo "$peer" >> "$ACTIVE_PEERS_FILE"
            else
                echo "✗ Inactive (removing)"
                ((removed_count++))
            fi
        fi
    done < "$PEER_NODES_FILE"
    
    echo "Removed $removed_count inactive peers"
}

# Function to fetch and test new peers from API
fetch_and_test_new_peers() {
    echo "Fetching live peers from Polkachu API..."
    
    # Fetch peers from API
    if ! curl -s -f "$API_URL" > "$TEMP_FILE"; then
        echo "Error: Failed to fetch peers from API"
        return 1
    fi
    
    # Parse JSON response and extract peers
    # The API returns JSON with a 'live_peers' array containing peer strings
    if ! jq -r '.live_peers[]?' "$TEMP_FILE" 2>/dev/null > "$NEW_PEERS_FILE"; then
        echo "Error: Failed to parse API response"
        return 1
    fi
    
    local added_count=0
    local tested_count=0
    
    echo "Testing new peers from API..."
    while IFS= read -r peer; do
        if [ -n "$peer" ]; then
            # Check if peer already exists in active peers
            if grep -Fxq "$peer" "$ACTIVE_PEERS_FILE" 2>/dev/null; then
                continue
            fi
            
            local host_port=$(extract_host_port "$peer")
            local host=$(echo "$host_port" | cut -d' ' -f1)
            local port=$(echo "$host_port" | cut -d' ' -f2)
            
            ((tested_count++))
            echo -n "Testing new peer $peer... "
            if test_port "$host" "$port"; then
                echo "✓ Active (adding)"
                echo "$peer" >> "$ACTIVE_PEERS_FILE"
                ((added_count++))
            else
                echo "✗ Inactive"
            fi
        fi
    done < "$NEW_PEERS_FILE"
    
    echo "Tested $tested_count new peers, added $added_count active ones"
}

# Function to update the peer nodes file
update_peer_nodes_file() {
    echo "Updating $PEER_NODES_FILE..."
    
    # Sort and deduplicate peers
    sort -u "$ACTIVE_PEERS_FILE" > "$PEER_NODES_FILE"
    
    local total_peers=$(wc -l < "$PEER_NODES_FILE")
    echo "Updated $PEER_NODES_FILE with $total_peers active peers"
}

# Main execution
main() {
    echo "Starting peer nodes update at $(date)"
    echo "========================================"
    
    # Test existing peers
    test_existing_peers
    
    echo ""
    
    # Fetch and test new peers
    fetch_and_test_new_peers
    
    echo ""
    
    # Update the peer nodes file
    update_peer_nodes_file
    
    echo "========================================"
    echo "Peer nodes update completed at $(date)"
}

# Cleanup function
cleanup() {
    rm -f "$TEMP_FILE" "$ACTIVE_PEERS_FILE" "$NEW_PEERS_FILE"
}

# Set trap for cleanup
trap cleanup EXIT

# Run main function
main
