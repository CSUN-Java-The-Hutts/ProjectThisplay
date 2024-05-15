import network
import socket
from time import sleep
from picozero import pico_temp_sensor, pico_led
import machine
import urequests

# Add your personal Wi-Fi info
ssid = "your wifi name"
password = "your wifi password"

def connect_to_wifi():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    wlan.connect(ssid, password)

    while not wlan.isconnected():
        print('Connecting to Wi-Fi...')
        sleep(1)

    ip = wlan.ifconfig()[0]
    print(f'Connected to Wi-Fi. IP: {ip}')
    return ip

def open_socket(ip, port=80):
    addr = (ip, port)
    server_socket = socket.socket()
    server_socket.bind(addr)
    server_socket.listen(1)
    return server_socket

def handle_client(client_socket):
    request = client_socket.recv(1024).decode()

    if request.startswith("POST /upload"):
        content_length = int(request.split("Content-Length: ")[1].split("\r\n")[0])
        file_content = client_socket.recv(content_length).decode()
        print("Received file content:")
        print(file_content)
        response = "HTTP/1.1 200 OK\nContent-Type: text/html\n\n<html><body><h1>File uploaded successfully</h1></body></html>"
    else:
        response = "HTTP/1.1 400 Bad Request\nContent-Type: text/html\n\n<html><body><h1>Invalid request</h1></body></html>"

    client_socket.sendall(response.encode())
    client_socket.close()

try:
    ip_address = connect_to_wifi()
    server_socket = open_socket(ip_address)

    while True:
        client_sock, client_addr = server_socket.accept()
        print(f'Client connected from {client_addr}')
        handle_client(client_sock)

except Exception as e:
    print(f"Error: {e}")
    machine.reset()
