class Crypt:
    """
    A Python class that replicates the functionality of the provided ActionScript Crypt class.
    """

    A_B64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    S_ENCRYPTION_KEY1 = "C41E3A52-6FB7-4289-8E0B-CD55BB0CD4B9"
    A_B64_LOOKUP = {char: i for i, char in enumerate(A_B64_CHARS)}

    @staticmethod
    def f_utf8_encode(s: str) -> str:
        """Encodes a string to UTF-8."""
        utftext = []
        for char_code in map(ord, s):
            if char_code < 128:
                utftext.append(chr(char_code))
            elif 127 < char_code < 2048:
                utftext.append(chr((char_code >> 6) | 0xC0))
                utftext.append(chr((char_code & 0x3F) | 0x80))
            else:
                utftext.append(chr((char_code >> 12) | 0xE0))
                utftext.append(chr(((char_code >> 6) & 0x3F) | 0x80))
                utftext.append(chr((char_code & 0x3F) | 0x80))
        return "".join(utftext)

    @staticmethod
    def f_encrypt(s_input: str, key: str) -> str:
        """Encrypts a string using a key."""
        s_utf8_encoded = Crypt.f_utf8_encode(s_input)
        return Crypt.f_encode_base64(s_utf8_encoded, key)

    @staticmethod
    def f_decode_base64(s_input: str, s_key: str) -> str:
        """Decodes a Base64 string with a key."""
        ret_val = []
        count = 0
        i = 0
        while i < len(s_input):
            char_value1 = Crypt.A_B64_LOOKUP[s_input[i]]
            char_value2 = Crypt.A_B64_LOOKUP[s_input[i + 1]]

            num = (char_value1 << 2 & 0xFF) | (char_value2 >> 4)
            ret_val.append(chr(num ^ ord(s_key[count % len(s_key)])))
            count += 1

            if s_input[i + 2] != "=":
                char_value3 = Crypt.A_B64_LOOKUP[s_input[i + 2]]
                num = (char_value2 << 4 & 0xFF) | (char_value3 >> 2)
                ret_val.append(chr(num ^ ord(s_key[count % len(s_key)])))
                count += 1

            if s_input[i + 3] != "=":
                char_value4 = Crypt.A_B64_LOOKUP[s_input[i + 3]]
                num = (char_value3 << 6 & 0xFF) | char_value4
                ret_val.append(chr(num ^ ord(s_key[count % len(s_key)])))
                count += 1

            i += 4
        return "".join(ret_val)

    @staticmethod
    def f_decrypt(s_input: str) -> str:
        """Decrypts a string."""
        return Crypt.f_utf8_decode(Crypt.f_decode_base64(s_input, Crypt.S_ENCRYPTION_KEY1))

    @staticmethod
    def f_encode_base64(s_input: str, s_key: str) -> str:
        """Encodes a string to a custom Base64 format with a key."""
        b64_enc_str = []
        bs_length = len(s_input)
        index = 0
        while index < bs_length:
            n_num = (ord(s_input[index]) ^ ord(s_key[index % len(s_key)])) >> 2
            b64_enc_str.append(Crypt.A_B64_CHARS[n_num])

            if bs_length - index == 1:
                n_num = (ord(s_input[index]) ^ ord(s_key[index % len(s_key)])) << 4 & 0x30
                b64_enc_str.append(Crypt.A_B64_CHARS[n_num])
                b64_enc_str.append("==")
                index += 1
            elif bs_length - index == 2:
                key_char1 = ord(s_key[index % len(s_key)])
                key_char2 = ord(s_key[(index + 1) % len(s_key)])
                n_num = ((ord(s_input[index]) ^ key_char1) << 4 & 0x30) | ((ord(s_input[index + 1]) ^ key_char2) >> 4)
                b64_enc_str.append(Crypt.A_B64_CHARS[n_num])
                n_num = (ord(s_input[index + 1]) ^ key_char2) << 2 & 0x3C
                b64_enc_str.append(Crypt.A_B64_CHARS[n_num])
                b64_enc_str.append("=")
                index += 2
            else:
                key_char1 = ord(s_key[index % len(s_key)])
                key_char2 = ord(s_key[(index + 1) % len(s_key)])
                key_char3 = ord(s_key[(index + 2) % len(s_key)])
                n_num = ((ord(s_input[index]) ^ key_char1) << 4 & 0x30) | ((ord(s_input[index + 1]) ^ key_char2) >> 4)
                b64_enc_str.append(Crypt.A_B64_CHARS[n_num])
                n_num = ((ord(s_input[index + 1]) ^ key_char2) << 2 & 0x3C) | ((ord(s_input[index + 2]) ^ key_char3) >> 6)
                b64_enc_str.append(Crypt.A_B64_CHARS[n_num])
                n_num = (ord(s_input[index + 2]) ^ key_char3) & 0x3F
                b64_enc_str.append(Crypt.A_B64_CHARS[n_num])
                index += 3
        return "".join(b64_enc_str)

    @staticmethod
    def f_utf8_decode(s_utftext: str) -> str:
        """Decodes a UTF-8 string."""
        string = []
        i = 0
        while i < len(s_utftext):
            c1 = ord(s_utftext[i])
            if c1 < 128:
                string.append(chr(c1))
                i += 1
            elif 193 < c1 <= 223:
                c2 = ord(s_utftext[i + 1])
                c1 = (c1 & 0x1F) << 6
                c2 &= 0x3F
                string.append(chr(c1 | c2))
                i += 2
            elif 224 <= c1 <= 239:
                c2 = ord(s_utftext[i + 1])
                c3 = ord(s_utftext[i + 2])
                c1 = (c1 & 0x0F) << 12
                c2 = (c2 & 0x3F) << 6
                c3 &= 0x3F
                string.append(chr(c1 | c2 | c3))
                i += 3
            elif 240 <= c1 <= 244:
                c2 = ord(s_utftext[i + 1])
                c3 = ord(s_utftext[i + 2])
                c4 = ord(s_utftext[i + 3])
                c1 = (c1 & 7) << 18
                c2 = (c2 & 0x3F) << 12
                c3 = (c3 & 0x3F) << 6
                c4 &= 0x3F
                string.append(chr(c1 | c2 | c3 | c4))
                i += 4
        return "".join(string)
