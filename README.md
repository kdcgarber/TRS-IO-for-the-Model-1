![Wireless-Keyboard](/images/trs-80MotherboardKeyBoard3.jpg?raw=true "Header")

# TRS-IO model 1

This repo is a snapshot of https://github.com/apuder/TRS-IO at f2acde6.<br>
That project is an amazing piece of hardware/software that provide new feature to my retro TRS-80 model 1<br>
- Network connection/ internet - TCP
- Retrostore
- SMB share 
- SD card
- FreHD emulation auto-boot on my unmodified M1
- Upper 32k of memory
- Virtual printer
- HDMI color video / audio out
- Realtime clock


<img src="https://github.com/kdcgarber/TRS-IO-for-the-Model-1/blob/main/images/WebPage.gif" width="300" height="300">
This is just notes for my path to get the v1.4 hardware build configured with the backported TRS-IO++ software that is all found on their site.<br>
These are my notes to help me build another in the future and may help someone (or may not).<br>


------  Notes  ------------

I used the ESP-WROOM-32 esp controller - https://www.amazon.com/dp/B0B764963C<br>
And I used the Tang Nano 9K FPGA - https://www.aliexpress.us/item/3256804089255675.html<br>


Prep:<br>
As a non-root account<br>

## Prep - installing required components<br>
sudo apt upgrade<br>
## On ubuntu 24.04, install the required apps<br>
## Packages for Espressif<br>
sudo apt-get install git wget flex bison gperf python3 python3-pip python3-setuptools cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 python3-virtualenv<br>
##  Packages for TRS-IO<br>
sudo apt-get install z80asm sdcc sdcc-libraries<br>
##  Some fixes for linking libraries that are needed by TRS-IO<br>
sudo mkdir -p /lib/z80/<br>
sudo ln -s /usr/share/sdcc/lib/z80/z80.lib /lib/z80/z80.lib<br>
##  Python3 as default:<br>
sudo apt-get install python3 python3-pip python3-setuptools<br>
sudo ln -s /usr/bin/python3 /usr/bin/python<br>
<br>

##  Install ESP-IDF<br>
cd ~/<br>
mkdir esp<br>
cd esp<br>
git clone -b v4.4.7 --recurse-submodules https://github.com/espressif/esp-idf.git<br>
cd ~/esp/esp-idf<br>
./install.sh esp32<br>



## TRS-IO stuff<br>
.  ~/esp/esp-idf/export.sh<br>
cd ~/esp<br>
git clone -b master --recurse-submodules https://github.com/apuder/TRS-IO.git <br>
cd ~/esp/TRS-IO/src/esp/ <br>



## Copy sdkconfig.trs-io-m1 to sdkconfig.trs-io-m1-v14<br>
cp sdkconfig.trs-io-m1 sdkconfig.trs-io-m1-v14<br>
<br>
## Then add to the bottom of the  sdkconfig.trs-io-m1-v14<br>
CONFIG_SPIRAM_SUPPORT=n<br>



## Added logging to the event handler   ~/esp/TRS-IO/src/esp/components/trs-io/http.cpp <br>
This is not require, it just lets you validate memory available as the webserver refreshes.<br>
    ESP_LOGI(TAG, "Free heap: %u", esp_get_free_heap_size());<br>

vim   ~/esp/TRS-IO/src/esp/components/trs-io/http.cpp <br>
It should look like this<br>

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




## Then lowered the max file value to save mem.<br>

vim components/trs-fs/posix.cpp<br>
 .max_files = 2,  // changed from 5<br>

<br><br>

			
## Then I change the  led to match the colors for the current v1.4 not ++ since mine are RGB not RBG<br>


At the top make these pin changes     led color change in ++ so need to change code to match 1.4 pcb<br>
vim ~/esp/TRS-IO/src/esp/main/led.cpp<br>
#ifdef CONFIG_TRS_IO_MODEL_1<br>
#define LED_RED 5<br>
#define LED_GREEN 4<br>
#define LED_BLUE 32<br>
<br>


#BUILD<br>
cd ~/esp/TRS-IO/src/esp<br>
idf.py fullclean<br>
make BOARD=trs-io-m1-v14 build<br>


Sometimes doing the flash fails. If it does, just try it again and it will load<br>
~/esp/esp-idf/components/esptool_py/esptool/esptool.py -p /dev/ttyUSB0  -b 460800 --before default_reset --after hard_reset --chip esp32  write_flash --flash_mode dio --flash_size detect --flash_freq 40m 0x1000 build/bootloader/bootloader.bin 0x8000 build/partition_table/partition-table.bin 0x10000 build/trs-io.bin 0x190000 build/html.bin<br>









##  To Flash the FPGA

The FPGA file is TRS-IO.fs<br>

cd  ~/esp/build<br>
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
		





