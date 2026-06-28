(module
  (memory 2)
  ;; मेमोरी लेआउट:
  ;; 0x0000: इनपुट स्ट्रिंग (UTF-8)
  ;; 0x1000: पार्स्ड डेटा स्ट्रक्ट
  ;;   0x1000: नाम (32 बाइट)
  ;;   0x1020: द्रव्यमान (f64)
  ;;   0x1028: स्थिति x, y, z (तीनों f64)
  ;;   0x1040: वेग x, y, z
  ;;   0x1058: बल (तीन f64)

  (global $input_ptr i32 (i32.const 0))
  (global $input_len i32 (i32.const 0))
  (global $pos i32 (i32.const 0))

  ;; ====== स्ट्रिंग से f64 पार्स (साधारण) ======
  (func $parse_f64 (param $start i32) (param $end i32) (result f64)
    ;; अभी सिर्फ पूर्णांक पढ़ता है, जैसे "2" या "10"
    (local $val f64) (local $i i32) (local $ch i32) (local $neg i32)
    f64.const 0
    local.set $val
    i32.const 0
    local.set $neg
    local.get $start
    local.set $i
    ;; नकारात्मक चिह्न
    local.get $i
    i32.load8_u
    i32.const 45  ;; '-'
    i32.eq
    if
      i32.const 1
      local.set $neg
      local.get $i
      i32.const 1
      i32.add
      local.set $i
    end
    loop $digit
      local.get $i
      local.get $end
      i32.ge_u
      if br $digit end
      local.get $i
      i32.load8_u
      local.tee $ch
      i32.const 48
      i32.lt_u
      local.get $ch
      i32.const 57
      i32.gt_u
      i32.or
      if br $digit end
      local.get $val
      f64.const 10.0
      f64.mul
      local.get $ch
      i32.const 48
      i32.sub
      f64.convert_i32_u
      f64.add
      local.set $val
      local.get $i
      i32.const 1
      i32.add
      local.set $i
      br $digit
    end
    local.get $neg
    if
      local.get $val
      f64.neg
      local.set $val
    end
    local.get $val
  )

  ;; ====== कीवर्ड जाँच ======
  (func $streq (param $p1 i32) (param $p2 i32) (param $len i32) (result i32)
    (local $i i32)
    loop $cmp
      local.get $i
      local.get $len
      i32.ge_u
      if i32.const 1 return end
      local.get $p1
      local.get $i
      i32.add
      i32.load8_u
      local.get $p2
      local.get $i
      i32.add
      i32.load8_u
      i32.ne
      if i32.const 0 return end
      local.get $i
      i32.const 1
      i32.add
      local.set $i
      br $cmp
    end
    i32.const 1
  )

  ;; ====== मुख्य पार्स फंक्शन (एक वस्तु) ======
  (func $parse_object (result i32)  ;; 1 अगर सफल
    (local $start i32) (local $end i32) (local $keyword_len i32)
    ;; "वस्तु" कीवर्ड ढूँढो
    ;; मान लो कि इनपुट में सबसे पहले "वस्तु" है
    ;; यहाँ हमें असल में टोकनाइज़र से कीवर्ड पढ़ना चाहिए, पर सरलता के लिए
    ;; हम मान लेते हैं कि इनपुट बिलकुल इस फॉर्मेट में है:
    ;; वस्तु "गेंद" : द्रव्यमान = 2
    ;; स्थिति = (0,10,0)
    ;; वेग = (5,0,0)
    ;; पर बल : गुरुत्वाकर्षण (0, -mass*9.8, 0)

    ;; स्किप "वस्तु "
    local.get $pos
    i32.const 0x0935  ;; 'व' का यूनिकोड कोडपॉइंट (UTF-8 में तीन बाइट: e0 a4 b5)
    ;; हम सीधे UTF-8 बाइट्स से तुलना करेंगे
    i32.load8_u
    i32.const 0xe0
    i32.ne
    if i32.const 0 return end
    ;; यहाँ पूरी तुलना लिखने की बजाय, हम मान लेते हैं कि इनपुट पहले से तय है और
    ;; हमने पहले ही वस्तु का नाम आदि मैन्युअली सेट कर दिया है (डेमो के लिए)।
    ;; असल में, पूर्ण WAT पार्सर बहुत लंबा होगा — हम इसे धीरे-धीरे बढ़ाएँगे।
    
    ;; अभी के लिए, हम सिर्फ एक नकली वस्तु बनाते हैं:
    ;; नाम = "गेंद" (0x1000 पर स्टोर)
    i32.const 0x1000
    i32.const 0x0917  ;; 'ग' (देवनागरी)
    i32.store16
    ;; बाकी नाम...
    ;; द्रव्यमान
    i32.const 0x1020
    f64.const 2.0
    f64.store
    ;; स्थिति
    i32.const 0x1028
    f64.const 0.0
    f64.store
    i32.const 0x1030
    f64.const 10.0
    f64.store
    i32.const 0x1038
    f64.const 0.0
    f64.store
    ;; वेग
    i32.const 0x1040
    f64.const 5.0
    f64.store
    i32.const 0x1048
    f64.const 0.0
    f64.store
    i32.const 0x1050
    f64.const 0.0
    f64.store
    i32.const 1
  )

  ;; ====== सिमुलेशन स्टेप (पिछली बार जैसा) ======
  (func $step (param $dt f64)
    (local $mass f64) (local $pos_y f64) (local $vel_y f64) (local $force_y f64) (local $acc_y f64)
    ;; ऑब्जेक्ट से डेटा लोड करें
    i32.const 0x1020
    f64.load
    local.set $mass
    i32.const 0x1030
    f64.load
    local.set $pos_y
    i32.const 0x1048
    f64.load
    local.set $vel_y

    ;; बल = -mass * 9.8
    local.get $mass
    f64.const 9.8
    f64.mul
    f64.neg
    local.set $force_y

    local.get $force_y
    local.get $mass
    f64.div
    local.set $acc_y

    local.get $vel_y
    local.get $acc_y
    local.get $dt
    f64.mul
    f64.add
    local.set $vel_y

    local.get $pos_y
    local.get $vel_y
    local.get $dt
    f64.mul
    f64.add
    local.set $pos_y

    ;; टकराव
    local.get $pos_y
    f64.const 0.0
    f64.le
    if
      local.get $vel_y
      f64.const -0.8
      f64.mul
      local.set $vel_y
      f64.const 0.0
      local.set $pos_y
    end

    ;; स्टोर वापस
    i32.const 0x1030
    local.get $pos_y
    f64.store
    i32.const 0x1048
    local.get $vel_y
    f64.store
  )

  (export "parse_object" (func $parse_object))
  (export "step" (func $step))
  (export "memory" (memory 0))
)
