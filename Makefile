UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
  OS:= darwin
endif
ifeq ($(UNAME_S),Linux)
  OS:= linux
endif
UNAME_M:= $(shell uname -m)
ifeq ($(UNAME_M),x86_64)
  ARCH:= amd64
endif

VERSION:= $(shell cat VERSION)
TARGET:= src/cli
RELEASE_DIR:= releases
OUTPUT:= ./$(RELEASE_DIR)/kce-$(VERSION)-$(OS)-$(ARCH)

.PHONY: all clean version prepare

all: clean prepare releases

releases: prepare version $(TARGET) pack docker
	docker run -it --rm -v ${PWD}/$(RELEASE_DIR):/app --entrypoint "sh" kce:$(VERSION) -c "cp /kce /app/kce-$(VERSION)-linux-amd64"

docker:
	docker build -t kce:$(VERSION) .
	docker tag kce:$(VERSION) kce:latest

prepare:
	@if [ ! -d ./$(RELEASE_DIR) ]; then mkdir ./$(RELEASE_DIR); fi

clean:
	@rm -f ./$(RELEASE_DIR)/*
	@echo >&2 "cleaned up"

version:
	@sed -i "" 's/^version:.*/version: $(VERSION)/g' shard.yml
	@echo "shard.yml updated with version $(VERSION)"

$(TARGET): % : prepare $(filter-out $(TEMPS), $(OBJ)) %.cr
	@crystal build src/cli.cr -o $(OUTPUT) --progress --release
	@rm ./$(RELEASE_DIR)/*.dwarf
	@echo "compiled binaries places to \"./$(RELEASE_DIR)\" directory"

pack:
	@find ./$(RELEASE_DIR) -type f -name "kce-$(VERSION)-$(OS)-$(ARCH)" | xargs upx
