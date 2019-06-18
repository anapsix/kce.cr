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
TARGET:= kcp
RELEASE_DIR:= ./releases
OUTPUT:= $(RELEASE_DIR)/$(TARGET)-$(VERSION)-$(OS)-$(ARCH)

.PHONY: all clean version

all: clean releases

releases: version $(TARGET) pack docker
	docker run -it --rm -v ${PWD}/releases:/app kcp cp /kcp /app/$(TARGET)-$(VERSION)-linux-amd64

docker: version
	docker build -t kcp .

clean:
	@rm -f $(RELEASE_DIR)/*
	@echo >&2 "cleaned up"

version:
	@sed -i "" 's/^VERSION.*/VERSION="$(VERSION)"/g' $(TARGET).cr
	@echo "Version set to $(VERSION)"

$(TARGET): % : $(filter-out $(TEMPS), $(OBJ)) %.cr
	@crystal build $@.cr -o $(OUTPUT) -p
	@echo "compiled binaries places to \"./releases\" directory"

pack:
	@find $(RELEASE_DIR) -type f -not -name "*.dwarf" | xargs upx
