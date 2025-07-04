![Wireless-Keyboard](/images/trs-80MotherboardKeyBoard3.jpg?raw=true "Header")

# TRS-IO model 1




------  Notes  ------------

For the ESP-WROOM-32 esp controller - https://www.amazon.com/dp/B0B764963C



As a non-root account

##Prep - installing required components

sudo apt upgrade

##On ubuntu 24.04, install the required apps

##Packages for Espressif

sudo apt-get install git wget flex bison gperf python3 python3-pip python3-setuptools cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 python3-virtualenv

## Packages for TRS-IO

sudo apt-get install z80asm sdcc sdcc-libraries

## Some fixes for linking libraries that are needed by TRS-IO

sudo mkdir -p /lib/z80/

sudo ln -s /usr/share/sdcc/lib/z80/z80.lib /lib/z80/z80.lib

## Python3 as default:

sudo apt-get install python3 python3-pip python3-setuptools

sudo ln -s /usr/bin/python3 /usr/bin/python


## Install ESP-IDF

cd ~/

mkdir esp

cd esp

git clone -b v4.4.7 --recurse-submodules https://github.com/espressif/esp-idf.git

cd ~/esp/esp-idf

./install.sh esp32



##TRS-IO stuff
.  ~/esp/esp-idf/export.sh
cd ~/esp
git clone -b master --recurse-submodules https://github.com/apuder/TRS-IO.git 
cd ~/esp/TRS-IO/src/esp/ 



##Copy sdkconfig.trs-io-m1 to sdkconfig.trs-io-m1-v14
cp sdkconfig.trs-io-m1 sdkconfig.trs-io-m1-v14

##Then add to the bottom of the  sdkconfig.trs-io-m1-v14
CONFIG_SPIRAM_SUPPORT=n



##Added logging to the event handler   ~/esp/TRS-IO/src/esp/components/trs-io/http.cpp 
This is not require, it just lets you validate memory available as the webserver refreshes.
    ESP_LOGI(TAG, "Free heap: %u", esp_get_free_heap_size());

vim   ~/esp/TRS-IO/src/esp/components/trs-io/http.cpp 
It should look like this

				static void mongoose_event_handler(struct mg_connection *c,
				                                   int event, void *eventData, void *fn_data)
				{
				  static bool reboot = false;
				
				  // Return if the web debugger is handling the request.
				  if (trx_handle_http_request(c, event, eventData, fn_data)) {
				    return;
				  }
				
				  switch (event) {
				  case MG_EV_HTTP_MSG:
				    {
				      struct mg_http_message* message = (struct mg_http_message*) eventData;
				      ESP_LOGI(TAG, "request %.*s %.*s",
				              message->method.len,
				              message->method.ptr,
				              message->uri.len,
				              message->uri.ptr);
				
				      ESP_LOGI(TAG, "Free heap: %u", esp_get_free_heap_size());
				
				      char* response = NULL; // Always allocated.
				      const char* content_type = "text/html"; // Never allocated




##Then lowered the max file value to save mem.

vim components/trs-fs/posix.cpp
 .max_files = 2,  // changed from 5



			
##Then I change the  led to match the colors for the current v1.4 not ++ since mine are RGB not RBG


At the top make these pin changes     led color change in ++ so need to change code to match 1.4 pcb
vim ~/esp/TRS-IO/src/esp/main/led.cpp
#ifdef CONFIG_TRS_IO_MODEL_1
#define LED_RED 5
#define LED_GREEN 4
#define LED_BLUE 32



#BUILD
cd ~/esp/TRS-IO/src/esp
idf.py fullclean
make BOARD=trs-io-m1-v14 build


Sometimes doing the flash fails. If it does, just try it again and it will load
~/esp/esp-idf/components/esptool_py/esptool/esptool.py -p /dev/ttyUSB0  -b 460800 --before default_reset --after hard_reset --chip esp32  write_flash --flash_mode dio --flash_size detect --flash_freq 40m 0x1000 build/bootloader/bootloader.bin 0x8000 build/partition_table/partition-table.bin 0x10000 build/trs-io.bin 0x190000 build/html.bin








## To Flash the FPGA
The build of the code came from matt boytim  --  mayoytim
The FPGA file is TRS-IO.fs

cd  ~/esp/build
openFPGALoader -b tangnano9k -f TRS-IO.fs

		EXAMPLE:
		root@thebox:/home/kdcgarber/esp/buildFiles# openFPGALoader -b tangnano9k -f TRS-IO.fs
		
		empty
		write to flash
		Jtag frequency : requested 6.00MHz   -> real 6.00MHz
		Parse file Parse TRS-IO.fs:
		Done
		DONE
		Jtag frequency : requested 2.50MHz   -> real 2.00MHz
		Erase SRAM DONE
		Erase FLASH DONE
		Erasing FLASH: [==================================================] 100.00%
		Done
		write Flash: [==================================================] 100.00%
		Done
		CRC check: Success
		





