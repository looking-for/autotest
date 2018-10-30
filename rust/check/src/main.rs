
extern crate pcap_file;
extern crate ether;
extern crate pktparse;

use std::process::Command;
use std::process::exit;
use std::thread;
use std::net::UdpSocket;
use std::fs::File;
use pcap_file::{PcapReader, PcapWriter};
use std::io::BufReader;
use std::io::BufRead;
use std::env::args;
use std::time::Duration;


/*
    -f pcap_file I M  json_file
    -s pcap_send.sh json_file
    check -f pcap_file I M [ json_file ]
    check -s pcap_send.sh [ json_file ]
*/

fn main() {
    let flag:i32;
    let mut pcap_send: String = String::new();
    let mut pcap_file: String = String::new();
    let mut pcap_send_m: String = String::new();
    let mut pcap_send_i: String = String::new();
    let mut json_file: String = String::new();

    let arg_count = std::env::args().count();
    if arg_count < 3{
       exit(1);
    }

    if arg_count == 6{
        if &(args().nth(1).unwrap()) != "-f"{
            exit(1);
        }

        flag = 1;
        pcap_file.push_str(&(args().nth(2).unwrap()));
        pcap_send_i.push_str(&(args().nth(3).unwrap()));
        pcap_send_m.push_str(&(args().nth(4).unwrap()));
        json_file.push_str(&(args().nth(5).unwrap()));

    }else if arg_count == 5{
        if &(args().nth(1).unwrap()) != "-f"{
            exit(1);
        }

        flag = 2;
        pcap_file.push_str(&(args().nth(2).unwrap()));
        pcap_send_i.push_str(&(args().nth(3).unwrap()));
        pcap_send_m.push_str(&(args().nth(4).unwrap()));

    }else if arg_count == 4{
        if &(args().nth(1).unwrap()) != "-s"{
            exit(1);
        }

        flag = 3;
        pcap_send.push_str(&(args().nth(2).unwrap()));
        json_file.push_str(&(args().nth(3).unwrap()));

    }else if arg_count == 3{
        if &(args().nth(1).unwrap()) != "-s"{
            exit(1);
        }

        flag = 4;
        pcap_send.push_str(&(args().nth(2).unwrap()));

    }else{
        exit(1);
    }

    let (sender_json_channel, receiver_json_channel) = std::sync::mpsc::channel();

    // must recv json first.
    let _json_ts = thread::spawn(move || {
        if flag == 1 || flag == 3{
            do_json(sender_json_channel, json_file);
        }
    });
    thread::sleep(Duration::from_secs(10));


    // send pcap files
    if flag == 1 || flag == 2 {

        let cmd = format!(" -i {} -M {} {}", pcap_send_i, pcap_send_m, pcap_file);
        let mut send_ts = match Command::new("tcpreplay")
            .arg(&cmd)
            .spawn() {
            Ok(t) => t,
            Err(_) => { exit(1); },
        };

        match send_ts.wait(){
            Ok(_) => {},
            Err(_) => {exit(1);},
        };

    }else if flag == 3 || flag == 4{

        let mut send_ts = match Command::new(&pcap_send)
            .spawn() {
            Ok(t) => t,
            Err(_) => { exit(1); },
        };

        match send_ts.wait(){
            Ok(_) => {},
            Err(_) => {exit(1);},
        };
    }

    if flag == 1 || flag == 3 {
        // notice.....
        // if sleep 10 secs, the json check not exit. we check it error.
        thread::sleep(Duration::from_secs(10));

        let _ = match receiver_json_channel.try_recv() {
            Ok(_) => {},
            Err(_) => { exit(1); },
        };
    }

    exit(0);
}


fn do_json(sender: std::sync::mpsc::Sender<i32>, file_name: String){
    let socket = match UdpSocket::bind("127.0.0.1:9293"){
        Ok(t) =>t,
        Err(_) => {exit(1)},
    };

    let file = match File::open(&file_name){
        Ok(t) => t,
        Err(_) => {exit(1);},
    };
    let pcap_reader = match PcapReader::new(file){
        Ok(t) => t,
        Err(_) => {exit(1)},
    };

    for pcap in pcap_reader{
        let packet = match pcap{
            Ok(t) => t,
            Err(_) => {exit(1)},
        };
        let (after_ether_packet, ether_packet) = match pktparse::ethernet::parse_ethernet_frame(&packet.data){
            Ok(t) => t,
            Err(_) => {exit(1);},
        };
        if ether_packet.ethertype != pktparse::ethernet::EtherType::IPv4{
            continue;
        }

        let ipv4_packet = ether::packet::network::ipv4::Packet::new(after_ether_packet);
        if ipv4_packet.protocol() != ether::packet::network::ipv4::Protocol::UDP{
            continue;
        }

        let udp_packet = ether::packet::transport::udp::Packet::new(ipv4_packet.payload());
        let json_buffer = udp_packet.payload();


        loop {

            let mut udp_buffer: Vec<u8> = Vec::new();

            let (rsize, _) = match socket.recv_from(udp_buffer.as_mut_slice()) {
                Ok(t) => t,
                Err(_) => { exit(1); },
            };

            if json_buffer == udp_buffer.as_mut_slice() {
                break;
            }
        }
    }

    match sender.send(1){
        Ok(_) => {},
        Err(_) => {exit(1)},

    };
    return;
}

/*
fn do_json(sender: std::sync::mpsc::Sender<i32>, file_name: String){
    let socket = match UdpSocket::bind("127.0.0.1:9293"){
        Ok(t) =>t,
        Err(_) => {exit(1)},
    };

    let file = match File::open(&file_name){
        Ok(t) => t,
        Err(_) => {exit(1);},
    };
    let pcap_reader = match PcapReader::new(file){
        Ok(t) => t,
        Err(_) => {exit(1)},
    };

    let mut json_reader = BufReader::new(file);

    for pcap in pcap_reader{
        let mut json_buffer: String = String::new();
        let jsize = match json_reader.read_line(&mut json_buffer) {
            Ok(t) => t,
            Err(_) => { exit(1); },
        };

        if jsize == 0{
            break;
        }

        loop {

            let mut udp_buffer: Vec<u8> = Vec::new();
            //let mut udp_buffer: String = String::new();

            let (rsize, _) = match socket.recv_from(udp_buffer.as_mut_slice()) {
                Ok(t) => t,
                Err(_) => { exit(1); },
            };

            let tmp = match String::from_utf8(udp_buffer){
                Ok(t) => t,
                Err(_) => {exit(1);},
            };

            if jsize == rsize && json_buffer ==  tmp{
                break;
            }
        }
    }

    match sender.send(1){
        Ok(_) => {},
        Err(_) => {exit(1)},

    };
    return;
}
*/