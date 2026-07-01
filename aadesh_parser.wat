(module
  (import "tokenizer" "memory" (memory 1))
  (import "tokenizer" "next_token" (func $next_token (result i32 i32 i32)))

  (global $token_type (mut i32) (i32.const 0))
  (global $token_start (mut i32) (i32.const 0))
  (global $token_len (mut i32) (i32.const 0))

  (func $read_token
    (local $type i32)
    (local $start i32)
    (local $len i32)
    call $next_token
    local.set $len
    local.set $start
    local.set $type
    local.get $type
    global.set $token_type
    local.get $start
    global.set $token_start
    local.get $len
    global.set $token_len
  )

  (func $parse_int_token (param $start i32) (param $len i32) (result i32)
    (local $i i32)
    (local $val i32)
    (local $ch i32)
    i32.const 0
    local.set $val
    i32.const 0
    local.set $i
    block $done
      loop $digits
        local.get $i
        local.get $len
        i32.ge_u
        if br $done end
        local.get $start
        local.get $i
        i32.add
        i32.load8_u
        local.set $ch
        local.get $ch
        i32.const 48
        i32.lt_u
        local.get $ch
        i32.const 57
        i32.gt_u
        i32.or
        if br $done end
        local.get $val
        i32.const 10
        i32.mul
        local.get $ch
        i32.const 48
        i32.sub
        i32.add
        local.set $val
        local.get $i
        i32.const 1
        i32.add
        local.set $i
        br $digits
      end
    end
    local.get $val
  )

  (func $parse (result i32)
    (local $prop_count i32)
    (local $entry_base i32)
    (local $parsed i32)
    (local $ch i32)

    call $read_token
    global.get $token_type
    i32.const 1
    i32.ne
    if i32.const 0 return end

    call $read_token
    global.get $token_type
    i32.const 3
    i32.ne
    if i32.const 0 return end

    i32.const 0x2000
    i32.const 1
    i32.store
    i32.const 0x2004
    global.get $token_start
    i32.store
    i32.const 0x2008
    global.get $token_len
    i32.store

    call $read_token
    global.get $token_type
    i32.const 4
    i32.ne
    if i32.const 0 return end
    global.get $token_start
    i32.load8_u
    i32.const 58
    i32.ne
    if i32.const 0 return end

    i32.const 0
    local.set $prop_count
    i32.const 0x200c
    local.get $prop_count
    i32.store

    block $done
      loop $properties
        call $read_token
        global.get $token_type
        i32.const -1
        i32.eq
        if br $done end

        global.get $token_type
        i32.const 4
        i32.eq
        if
          global.get $token_start
          i32.load8_u
          i32.const 44
          i32.eq
          if br $properties end
        end

        local.get $prop_count
        i32.const 24
        i32.mul
        i32.const 0x2010
        i32.add
        local.set $entry_base

        local.get $entry_base
        global.get $token_start
        i32.store
        local.get $entry_base
        i32.const 4
        i32.add
        global.get $token_len
        i32.store

        call $read_token
        global.get $token_type
        i32.const 4
        i32.ne
        if i32.const 0 return end
        global.get $token_start
        i32.load8_u
        i32.const 61
        i32.ne
        if i32.const 0 return end

        call $read_token
        global.get $token_type
        i32.const 2
        i32.eq
        if
          global.get $token_start
          global.get $token_len
          call $parse_int_token
          local.set $parsed
          local.get $entry_base
          i32.const 8
          i32.add
          i32.const 1
          i32.store
          local.get $entry_base
          i32.const 12
          i32.add
          local.get $parsed
          i32.store
          local.get $entry_base
          i32.const 16
          i32.add
          i32.const 0
          i32.store
          local.get $entry_base
          i32.const 20
          i32.add
          i32.const 0
          i32.store
        else
          global.get $token_type
          i32.const 4
          i32.eq
          if
            global.get $token_start
            i32.load8_u
            i32.const 40
            i32.eq
            if
              call $read_token
              global.get $token_type
              i32.const 2
              i32.ne
              if i32.const 0 return end
              global.get $token_start
              global.get $token_len
              call $parse_int_token
              local.set $parsed
              local.get $entry_base
              i32.const 8
              i32.add
              i32.const 2
              i32.store
              local.get $entry_base
              i32.const 12
              i32.add
              local.get $parsed
              i32.store
              call $read_token
              global.get $token_type
              i32.const 4
              i32.ne
              if i32.const 0 return end
              global.get $token_start
              i32.load8_u
              i32.const 44
              i32.ne
              if i32.const 0 return end
              call $read_token
              global.get $token_type
              i32.const 2
              i32.ne
              if i32.const 0 return end
              global.get $token_start
              global.get $token_len
              call $parse_int_token
              local.set $parsed
              local.get $entry_base
              i32.const 16
              i32.add
              local.get $parsed
              i32.store
              call $read_token
              global.get $token_type
              i32.const 4
              i32.ne
              if i32.const 0 return end
              global.get $token_start
              i32.load8_u
              i32.const 44
              i32.ne
              if i32.const 0 return end
              call $read_token
              global.get $token_type
              i32.const 2
              i32.ne
              if i32.const 0 return end
              global.get $token_start
              global.get $token_len
              call $parse_int_token
              local.set $parsed
              local.get $entry_base
              i32.const 20
              i32.add
              local.get $parsed
              i32.store
              call $read_token
              global.get $token_type
              i32.const 4
              i32.ne
              if i32.const 0 return end
              global.get $token_start
              i32.load8_u
              i32.const 41
              i32.ne
              if i32.const 0 return end
            else
              global.get $token_type
              i32.const 3
              i32.eq
              if
                local.get $entry_base
                i32.const 8
                i32.add
                i32.const 3
                i32.store
                local.get $entry_base
                i32.const 12
                i32.add
                global.get $token_start
                i32.store
                local.get $entry_base
                i32.const 16
                i32.add
                global.get $token_len
                i32.store
                local.get $entry_base
                i32.const 20
                i32.add
                i32.const 0
                i32.store
              else
                local.get $entry_base
                i32.const 8
                i32.add
                i32.const 0
                i32.store
                local.get $entry_base
                i32.const 12
                i32.add
                i32.const 0
                i32.store
                local.get $entry_base
                i32.const 16
                i32.add
                i32.const 0
                i32.store
                local.get $entry_base
                i32.const 20
                i32.add
                i32.const 0
                i32.store
              end
            end
          end
        end

        local.get $prop_count
        i32.const 1
        i32.add
        local.set $prop_count
        i32.const 0x200c
        local.get $prop_count
        i32.store

        call $read_token
        global.get $token_type
        i32.const -1
        i32.eq
        if br $done end
        global.get $token_type
        i32.const 4
        i32.eq
        if
          global.get $token_start
          i32.load8_u
          i32.const 44
          i32.eq
          if br $properties end
        end
        br $done
      end
    end
    i32.const 1
  )

  (export "parse" (func $parse))
)
