//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.9 Beta-4 Education
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Sat Jun 08 10:03:06 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    blk_mem_gen_2 your_instance_name(
        .douta(douta_o), //output [7:0] douta
        .doutb(doutb_o), //output [7:0] doutb
        .clka(clka_i), //input clka
        .ocea(ocea_i), //input ocea
        .cea(cea_i), //input cea
        .reseta(reseta_i), //input reseta
        .wrea(wrea_i), //input wrea
        .clkb(clkb_i), //input clkb
        .oceb(oceb_i), //input oceb
        .ceb(ceb_i), //input ceb
        .resetb(resetb_i), //input resetb
        .wreb(wreb_i), //input wreb
        .ada(ada_i), //input [9:0] ada
        .dina(dina_i), //input [7:0] dina
        .adb(adb_i), //input [9:0] adb
        .dinb(dinb_i) //input [7:0] dinb
    );

//--------Copy end-------------------
