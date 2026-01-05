# combo-safe
This was done for a lab in my CPEN 211 course. I worked on this with a partner.

When testing with,1 FPGA board. You must use the switches to input a hexadecimal digit for the password character. Then press KEY[1] to submit the character into the buffer. You can only set a password of 6 such characters, no less no more. To save the password, you must set switches to hexadecimal digit ‘e’ and press KEY[1] after you have entered 6 digits. To reset at any point of entering or setting the password, set the switches to hexadecimal digit ‘f’ and press KEY[1]. 

The picture above shows operation with two FPGA boards. The entry of characters was done with a keypad instead of the switches. Submitting the character was done with ‘#’ characters instead of KEY[1]. A separate keyboard module was written by my partner that transmitted key presses from the keypad  to the FPGA board. Without the keyboard module, my module could not have worked with the keypad. Our boards were connected together and to the keypad with Arduino wires.
