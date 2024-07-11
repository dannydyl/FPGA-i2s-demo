#include <iostream>
#include <fstream>
#include <boost/asio.hpp>

using namespace std;
using namespace boost::asio;

int main() {
    try {
        // Open the serial port (adjust COM port and baud rate as needed)
        io_service io;
        serial_port serial(io, "/dev/ttyUSB0"); // Replace with your COM port
        serial.set_option(serial_port_base::baud_rate(9600));
        serial.set_option(serial_port_base::character_size(8));
        serial.set_option(serial_port_base::parity(serial_port_base::parity::none));
        serial.set_option(serial_port_base::stop_bits(serial_port_base::stop_bits::one));
        serial.set_option(serial_port_base::flow_control(serial_port_base::flow_control::none));

        // Open a text file for writing
        ofstream file("audio_data.txt");

        if (!file.is_open()) {
            cerr << "Failed to open file" << endl;
            return 1;
        }

        char data[1];
        int data_count = 0;
        while (true) {
            // Read data from serial port
            read(serial, buffer(data, 1));

            // Write to file and print to console (optional)
            file << hex << static_cast<int>(data[0]) << endl;
            cout << hex << static_cast<int>(data[0]) << endl;

            data_count++;
            if (data_count >= 3000) {
                break; // Exit after capturing 3000 samples
            }
        }

        file.close();
        cout << "Data capture complete. Saved to audio_data.txt." << endl;
    } catch (boost::system::system_error& e) {
        cerr << "Error: " << e.what() << endl;
        return 1;
    }

    return 0;
}
