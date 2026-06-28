(module
  (memory 1)
  ;; जिन्हें बदलना नहीं है — immutable
  (global $mass f64 (f64.const 2.0))
  (global $pos_x f64 (f64.const 0.0))
  (global $vel_x f64 (f64.const 5.0))

  ;; जिन्हें बदलना है — mutable (mut जोड़ा गया)
  (global $pos_y (mut f64) (f64.const 10.0))
  (global $vel_y (mut f64) (f64.const 0.0))

  (func $step (param $dt f64)
    (local $force_y f64)
    (local $acc_y f64)

    ;; F_y = -mass * 9.8
    global.get $mass
    f64.const 9.8
    f64.mul
    f64.neg
    local.set $force_y

    ;; a_y = F_y / mass
    local.get $force_y
    global.get $mass
    f64.div
    local.set $acc_y

    ;; v_y += a_y * dt
    global.get $vel_y
    local.get $acc_y
    local.get $dt
    f64.mul
    f64.add
    global.set $vel_y

    ;; y += v_y * dt
    global.get $pos_y
    global.get $vel_y
    local.get $dt
    f64.mul
    f64.add
    global.set $pos_y

    ;; टकराव (ज़मीन से)
    global.get $pos_y
    f64.const 0.0
    f64.le
    if
      global.get $vel_y
      f64.const -0.8
      f64.mul
      global.set $vel_y
      f64.const 0.0
      global.set $pos_y
    end
  )

  (export "step" (func $step))
  (export "get_pos_y" (global $pos_y))
  (export "get_vel_y" (global $vel_y))
)
