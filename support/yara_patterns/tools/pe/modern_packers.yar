/*
 * YARA rules from Neo23x0/signature-base
 * Source: https://github.com/Neo23x0/signature-base
 * License: Detection Rule License (DRL) 1.1
 * https://github.com/Neo23x0/signature-base/blob/master/LICENSE
 *
 * Integrated into RetDec: 2025-11-03
 * Original authors: Florian Roth and contributors
 */

/*
   Yara Rule Set
   Author: Florian Roth with the help of binar.ly
   Date: 2017-05-02
   Identifier: Enigma Protector
*/

rule EnigmaPacker_Rare {
   meta:
      description = "Detects an ENIGMA packed executable"
      license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
      author = "Florian Roth (Nextron Systems)"
      reference = "Internal Research"
      date = "2017-04-27"
      score = 60
      hash1 = "77be6e80a4cfecaf50d94ee35ddc786ba1374f9fe50546f1a3382883cb14cec9"
      id = "748bc74c-e83f-5740-8ff7-f1371fc22802"
   strings:
      $s1 = "P.rel$oc$" fullword ascii
      $s2 = "ENIGMA" fullword ascii
   condition:
      ( uint16(0) == 0x5a4d and filesize < 4000KB and all of them )
}

rule Enigma_Protected_Malware_May17_RhxFiles {
   meta:
      description = "Auto-generated rule - file RhxFiles.dll"
      author = "Florian Roth (Nextron Systems) with the help of binar.ly"
      reference = "Internal Research"
      date = "2017-05-02"
      hash1 = "2187d6bd1794bf7b6199962d8a8677f19e4382a124c30933d01aba93cc1f0f15"
      id = "d701d591-4283-5645-8768-a5ab7df0f37a"
   strings:
      $op1 = { bd 9c 74 f6 7a 3a f7 94 c5 7d 7c 7c 7c 7e ae 73 }
      $op2 = { 82 62 6b 6b 6b 68 a5 ea aa 69 6b 6b 6b 3a 3b 94 }
      $op3 = { 7c 7c c5 7d 7c 7c 7c 7e ae 73 f9 79 7c 7c 7c f6 }
   condition:
      ( uint16(0) == 0x5a4d and filesize < 4000KB and all of them )
}

rule Enigma_Protected_Malware {
   meta:
      description = "Detects samples packed by Enigma Protector"
      author = "Florian Roth (Nextron Systems) with the help of binar.ly"
      reference = "https://goo.gl/OEVQ9w"
      date = "2017-02-03"
      hash1 = "d4616f9706403a0d5a2f9a8726230a4693e4c95c58df5c753ccc684f1d3542e2"
      id = "d701d591-4283-5645-8768-a5ab7df0f37a"
   strings:
      $s1 = { 5d 5d 5d aa bf 5e 95 d6 dc 51 5d 5d 5d 5e 98 0d }
      $s2 = { 52 d9 47 5d 5d 5d dd a6 b4 52 d9 4c 5d 5d 5d 3b }
      $s3 = { 9f 59 14 52 d8 a9 a2 a2 a2 00 9f 51 5d d6 d1 79 }
   condition:
      ( uint16(0) == 0x5a4d and filesize < 2000KB and all of them )
}

rule mal_lockbit4_packed_feb24
{
    meta:
        author = "0x0d4y"
        description = "Detect the packer used by Lockbit4.0"
        date = "2024-02-16"
        score = 100
        reference = "https://0x0d4y.blog/lockbit4-0-evasion-tales/"
        hash = "15796971D60F9D71AD162060F0F76A02"
        uuid = "3c2b2806-9dce-4dce-a7ca-89ebc9005695"
        license = "CC BY 4.0"
        rule_matching_tlp = "TLP:WHITE"
        rule_sharing_tlp = "TLP:WHITE"
        malpedia_family = "win.lockbit"
    strings:
        $unpacking_loop_64b = { 8b 1e 48 83 ee fc 11 db 8a 16 72 e5 8d 41 01 41 ff d3 11 c0 01 db 75 0a }
        $jump_to_unpacked_code_64b = { 48 8b 2d 16 0f ?? ?? 48 8d be 00 f0 ?? ?? bb 00 ?? ?? ?? 50 49 89 e1 41 b8 04 ?? ?? ?? 53 5a 90 57 59 90 48 83 ec ?? ff d5 48 8d 87 ?? ?? ?? ?? 80 20 ?? 80 60 ?? ?? 4c 8d 4c 24 ?? 4d 8b 01 53 90 5a 90 57 59 ff d5 48 83 c4 ?? 5d 5f 5e 5b 48 8d 44 24 ?? 6a ?? 48 39 c4 75 f9 48 83 ec ?? e9 }
        $unpacking_loop_32b = { 8A 06 46 88 07 47 01 DB 75 ?? 8B 1E 83 EE ?? 11 DB 72 ?? 9C 29 C0 40 9D 01 DB 75 ?? 8B 1E 83 EE ?? 11 DB 11 C0 01 DB 73 ?? 75 ?? 8B 1E 83 EE ?? 11 DB 73 }
        $jump_to_unpacked_code_32b = { 8b ae ?? ?? ?? ?? 8d be 00 f0 ?? ?? bb 00 ?? ?? ?? 50 54 6a 04 53 57 ff d5 8d 87 ?? ?? ?? ?? 80 20 ?? 80 60 ?? ?? 58 50 54 50 53 57 ff d5 58 8d 9e 00 f0 ?? ?? 8d bb ?? ?? ?? ?? 57 31 c0 aa 59 49 50 6a 01 53 ff d1 61 8d 44 24 ?? 6a ?? 39 c4 75 fa 83 ec ?? e9 }

    condition:
        uint16(0) == 0x5a4d and
        1 of ($jump_to_unpacked_code_*) and
        1 of ($unpacking_loop_*)
}
