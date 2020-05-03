BIN = bin/stats
SRC = ./stats
IMG = akashnet/stats

bin: $(SRC)
	go build -o $(BIN) $(SRC)
	GOOS=linux GOARCH=amd64 go build -o $(BIN)_linux_amd64 $(SRC)
	GOOS=darwin GOARCH=amd64 go build -o $(BIN)_darwin_amd64 $(SRC)

clean:
	rm -rf data bin

image:
	docker build -t $(IMG) .

image-push:
	docker push $(IMG)

image-run:
	docker run --rm -p 3001:3001 -e PORT=3001 $(IMG)

.PHONY: bin clean

verify-gentx:
	sh akash_verify_gentx.sh
