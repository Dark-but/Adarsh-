(module
  (memory (export "memory") 1)

  (global $input_ptr (mut i32) (i32.const 0))
  (global $input_len (mut i32) (i32.const 0))
  (global $pos (mut i32) (i32.const 0))

  (func $init (param $len i32)
    i32.const 0
    global.set $input_ptr
    local.get $len
    global.set $input_len
    i32.const 0
    global.set $pos
  )

  (func $next_token (result i32 i32 i32)
    (local $type i32)
    (local $start i32)
    (local $len i32)
    (local $ch i32)

    loop $skip
      global.get $pos
      global.get $input_len
      i32.ge_u
      if
        i32.const -1
        i32.const 0
        i32.const 0
        return
      end

      global.get $pos
      i32.load8_u
      local.set $ch

      local.get $ch
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
        global.get $pos
        i32.const 1
        i32.add
        global.set $pos
        br $skip
      end
    end

    global.get $pos
    local.set $start

    global.get $pos
    i32.load8_u
    local.set $ch

    local.get $ch
    i32.const 48
    i32.ge_u
    local.get $ch
    i32.const 57
    i32.le_u
    i32.and
    if
      i32.const 2
      local.set $type
      block $done
        loop $number
          global.get $pos
          i32.const 1
          i32.add
          global.set $pos
          global.get $pos
          global.get $input_len
          i32.ge_u
          if br $done end
          global.get $pos
          i32.load8_u
          local.set $ch
          local.get $ch
          i32.const 48
          i32.ge_u
          local.get $ch
          i32.const 57
          i32.le_u
          i32.and
          if br $number end
        end
      end
      global.get $pos
      local.get $start
      i32.sub
      local.set $len
      local.get $type
      local.get $start
      local.get $len
      return
    end

    local.get $ch
    i32.const 34
    i32.eq
    if
      i32.const 3
      local.set $type
      global.get $pos
      i32.const 1
      i32.add
      global.set $pos
      global.get $pos
      local.set $start
      block $done
        loop $string
          global.get $pos
          global.get $input_len
          i32.ge_u
          if br $done end
          global.get $pos
          i32.load8_u
          local.set $ch
          local.get $ch
          i32.const 34
          i32.eq
          if br $done end
          global.get $pos
          i32.const 1
          i32.add
          global.set $pos
          br $string
        end
      end
      global.get $pos
      local.get $start
      i32.sub
      local.set $len
      local.get $type
      local.get $start
      local.get $len
      return
    end

    local.get $ch
    i32.const 58
    i32.eq
    local.get $ch
    i32.const 61
    i32.eq
    i32.or
    local.get $ch
    i32.const 44
    i32.eq
    i32.or
    local.get $ch
    i32.const 40
    i32.eq
    i32.or
    local.get $ch
    i32.const 41
    i32.eq
    i32.or
    if
      i32.const 4
      local.set $type
      global.get $pos
      i32.const 1
      i32.add
      global.set $pos
      local.get $start
      i32.const 1
      local.set $len
      local.get $type
      local.get $start
      local.get $len
      return
    end

    i32.const 1
    local.set $type
    global.get $pos
    i32.const 1
    i32.add
    global.set $pos
    local.get $start
    i32.const 1
    local.set $len
    local.get $type
    local.get $start
    local.get $len
    return
  )

  (export "init" (func $init))
  (export "next_token" (func $next_token))
)
