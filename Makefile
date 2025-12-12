BOARD_TAG = uno
ARDUINO_PORT = /dev/ttyUSB0
ARDUINO_LIBS =
MCU = atmega328p
F_CPU = 16000000
PROJECT_DIR = $(CURDIR)
BUILD_DIR = $(PROJECT_DIR)/build
SRC_DIR = $(PROJECT_DIR)/main
TARGET = $(notdir $(CURDIR))
MAIN_SKETCH = $(SRC_DIR)/main.ino
SOURCES = $(wildcard $(SRC_DIR)/*.cpp) $(wildcard $(SRC_DIR)/*.c) $(MAIN_SKETCH)
HEADERS = $(wildcard $(SRC_DIR)/*.h)

ARDUINO_CLI = arduino-cli
ARDUINO_CLI_FLAGS =
AVRDUDE = avrdude
AVRDUDE_CONF = /etc/avrdude.conf

all: compile upload

compile: $(BUILD_DIR)/$(TARGET).hex

$(BUILD_DIR)/$(TARGET).hex: $(SOURCES) $(HEADERS)
	@mkdir -p $(BUILD_DIR)
	$(ARDUINO_CLI) compile $(ARDUINO_CLI_FLAGS) \
		--build-path $(BUILD_DIR) \
		--fqbn arduino:avr:$(BOARD_TAG) \
		$(MAIN_SKETCH)

upload: $(BUILD_DIR)/$(TARGET).hex
	$(ARDUINO_CLI) upload $(ARDUINO_CLI_FLAGS) \
		--port $(ARDUINO_PORT) \
		--fqbn arduino:avr:$(BOARD_TAG) \
		--input-dir $(BUILD_DIR) \
		$(MAIN_SKETCH)

clean:
	rm -rf $(BUILD_DIR)

monitor:
	screen $(ARDUINO_PORT) 9600

.PHONY: all compile upload clean monitor
