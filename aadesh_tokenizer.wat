(module
  ;; मेमोरी: पहला पेज टोकन स्टोर करने के लिए
  (memory 1)
  
  ;; इनपुट स्ट्रिंग का पॉइंटर और लंबाई
  (global $input_ptr i32 (i32.const 0))
  (global $input_len i32 (i32.const 0))
  
  ;; वर्तमान पढ़ने की स्थिति
  (global $pos i32 (i32.const 0))
  
  ;; --- टोकन प्रकार (enum) ---
  ;; 0 = KEYWORD (जैसे "वस्तु", "नियतांक")
  ;; 1 = IDENTIFIER (नाम)
  ;; 2 = NUMBER
  ;; 3 = SYMBOL (जैसे ':', '{', '}')
  
  ;; --- मुख्य फंक्शन: एक टोकन पढ़ें ---
  (func $next_token (result i32 i32 i32)
    ;; लौटाएगा: type, start_ptr, length
    ;; अभी के लिए सिर्फ एक आसान स्कैनर — स्पेस छोड़ें और शब्द पकड़ें
    (local $start i32)
    (local $len i32)
    
    ;; स्पेस और न्यूलाइन स्किप करें
    loop $skip
      local.get $pos
      local.get $input_len
      i32.ge_u
      if (result i32) i32.const -1 return end
      
      local.get $pos
      i32.load8_u
      local.tee $ch
      ;; स्पेस, \n, \r, \t छोड़ें
      i32.const 32
      i32.eq
      local.get $ch
      i32.const 10
      i32.eq
      i32.or
      local.get $ch
      i32.const 13
      i32.eq
      i32.or
      local.get $ch
      i32.const 9
      i32.eq
      i32.or
      if
        local.get $pos
        i32.const 1
        i32.add
        global.set $pos
        br $skip
      end
    end
    
    ;; अब शब्द या प्रतीक पकड़ें
    local.get $pos
    local.set $start
    local.get $pos
    i32.load8_u
    local.tee $ch
    
    ;; अगर अक्षर है (देवनागरी या अंग्रेज़ी) — पूरा शब्द पढ़ें
    i32.const 65   ;; 'A'
    i32.ge_u
    if  ;; सरलता के लिए अभी ASCII ही मान लेते हैं (बाद में UTF-8 जोड़ेंगे)
      loop $word
        local.get $pos
        i32.const 1
        i32.add
        global.set $pos
        local.get $pos
        local.get $input_len
        i32.ge_u
        if (result i32) br $word end
        local.get $pos
        i32.load8_u
        ;; रुकें अगर स्पेस, कोलन, ब्रेस आदि
        local.tee $ch
        i32.const 32
        i32.le_u
        if br $word end
        local.get $ch
        i32.const 58  ;; ':'
        i32.eq
        if br $word end
        local.get $ch
        i32.const 123 ;; '{'
        i32.eq
        if br $word end
        local.get $ch
        i32.const 125 ;; '}'
        i32.eq
        if br $word end
        br $word  ;; फिलहाल सिर्फ एक अक्षर पकड़ें, बाद में सुधारेंगे
      end
      local.get $start
      local.get $pos
      local.get $start
      i32.sub
      return
    else
      ;; विशेष चिह्न (:, {, })
      local.get $pos
      i32.const 1
      i32.add
      global.set $pos
      local.get $start
      i32.const 1
      return
    end
  )
  
  (export "next_token" (func $next_token))
)
