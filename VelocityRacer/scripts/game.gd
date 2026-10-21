extends Node3D

var car: Node3D
var camera: Camera3D
var speed := 0.0
var distance := 0.0
var nitro := 100.0
var left_down := false
var right_down := false
var gas_down := false
var brake_down := false
var nitro_down := false
var speed_text: Label
var distance_text: Label
var nitro_bar: ProgressBar

func _ready() -> void:
    _setup_world()
    _setup_road()
    _setup_car()
    _setup_hud()

func _process(delta: float) -> void:
    var gas = Input.is_action_pressed("accelerate") or gas_down
    var brake = Input.is_action_pressed("brake") or brake_down
    var left = Input.is_action_pressed("steer_left") or left_down
    var right = Input.is_action_pressed("steer_right") or right_down
    var boost = (Input.is_action_pressed("nitro") or nitro_down) and nitro > 0.0 and speed > 8.0
    var top_speed = 58.0 if not boost else 76.0
    speed = move_toward(speed, top_speed if gas or boost else (0.0 if brake else 8.0), (24.0 if gas or boost else (42.0 if brake else 5.0)) * delta)
    nitro = maxf(0.0, nitro - 28.0 * delta) if boost else minf(100.0, nitro + 8.0 * delta)
    var steer = float(right) - float(left)
    car.position.x = clampf(car.position.x + steer * (2.2 + speed * 0.045) * delta, -6.5, 6.5)
    car.rotation.z = lerpf(car.rotation.z, -steer * 0.08, 4.0 * delta)
    distance += speed * delta
    _move_road(delta)
    camera.position = camera.position.lerp(Vector3(car.position.x * 0.35, 5.0, 10.5), 3.0 * delta)
    camera.look_at(Vector3(car.position.x * 0.3, 0.5, -8.0), Vector3.UP)
    speed_text.text = "%03d km/h" % int(speed * 3.6)
    distance_text.text = "DISTANCE  %05d m" % int(distance)
    nitro_bar.value = nitro

func _setup_world() -> void:
    var env_node = WorldEnvironment.new()
    var env = Environment.new()
    env.background_mode = Environment.BG_SKY
    var sky = Sky.new()
    var sky_mat = ProceduralSkyMaterial.new()
    sky_mat.sky_top_color = Color(0.025, 0.06, 0.14)
    sky_mat.sky_horizon_color = Color(0.85, 0.28, 0.12)
    sky.sky_material = sky_mat
    env.sky = sky
    env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env_node.environment = env
    add_child(env_node)
    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -25, 0)
    sun.light_energy = 1.35
    add_child(sun)

func _setup_road() -> void:
    _make_box(Vector3(18, 0.2, 220), Vector3(0, -0.2, -85), Color(0.09, 0.105, 0.13))
    _make_box(Vector3(0.22, 0.03, 220), Vector3(-8.5, -0.07, -85), Color(1.0, 0.24, 0.08))
    _make_box(Vector3(0.22, 0.03, 220), Vector3(8.5, -0.07, -85), Color(1.0, 0.24, 0.08))
    for z in range(-190, 20, 12):
        _make_box(Vector3(0.12, 0.035, 4.0), Vector3(0, -0.07, z), Color(0.78, 0.8, 0.84))
    for i in range(18):
        var z = -float(i) * 13.0 - 12.0
        var h = 4.0 + float((i * 7) % 9)
        var w = 3.0 + float((i * 3) % 5)
        var side = -1.0 if i % 2 == 0 else 1.0
        _make_box(Vector3(w, h, 5), Vector3(side * (15.0 + float((i * 11) % 18)), h / 2.0, z), Color(0.07, 0.09, 0.14))

func _setup_car() -> void:
    car = Node3D.new()
    add_child(car)
    _make_box(Vector3(1.8, 0.52, 3.7), Vector3(0, 0.55, 0), Color(0.78, 0.055, 0.035), car)
    _make_box(Vector3(1.3, 0.48, 1.5), Vector3(0, 0.98, -0.12), Color(0.035, 0.07, 0.11), car)
    _make_box(Vector3(1.4, 0.1, 0.8), Vector3(0, 0.83, -1.2), Color(0.92, 0.12, 0.04), car)
    for x in [-0.92, 0.92]:
        for z in [-1.2, 1.2]:
            var wheel = MeshInstance3D.new()
            var mesh = CylinderMesh.new()
            mesh.top_radius = 0.32
            mesh.bottom_radius = 0.32
            mesh.height = 0.2
            wheel.mesh = mesh
            wheel.position = Vector3(x, 0.3, z)
            wheel.rotation.z = PI / 2.0
            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color(0.02, 0.025, 0.03)
            wheel.material_override = mat
            car.add_child(wheel)
    camera = Camera3D.new()
    camera.position = Vector3(0, 5, 10.5)
    camera.fov = 72
    add_child(camera)
    camera.current = true
    camera.look_at(Vector3(0, 0.5, -8), Vector3.UP)

func _setup_hud() -> void:
    var layer = CanvasLayer.new()
    add_child(layer)
    speed_text = Label.new()
    speed_text.position = Vector2(28, 24)
    speed_text.add_theme_font_size_override("font_size", 34)
    speed_text.add_theme_color_override("font_color", Color(1, 0.38, 0.12))
    layer.add_child(speed_text)
    distance_text = Label.new()
    distance_text.position = Vector2(30, 66)
    distance_text.add_theme_font_size_override("font_size", 18)
    layer.add_child(distance_text)
    nitro_bar = ProgressBar.new()
    nitro_bar.position = Vector2(30, 100)
    nitro_bar.size = Vector2(250, 14)
    nitro_bar.max_value = 100
    nitro_bar.show_percentage = false
    layer.add_child(nitro_bar)
    _add_button(layer, "◀", Vector2(24, -112), Vector2(88, 76), "left")
    _add_button(layer, "▶", Vector2(120, -112), Vector2(88, 76), "right")
    _add_button(layer, "BRAKE", Vector2(-208, -112), Vector2(88, 76), "brake")
    _add_button(layer, "GAS", Vector2(-112, -112), Vector2(88, 76), "gas")
    _add_button(layer, "N₂O", Vector2(-112, -198), Vector2(88, 68), "nitro")

func _add_button(layer: CanvasLayer, caption: String, offset: Vector2, dimensions: Vector2, action: String) -> void:
    var button = Button.new()
    button.text = caption
    button.size = dimensions
    button.focus_mode = Control.FOCUS_NONE
    button.add_theme_font_size_override("font_size", 20)
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.035, 0.055, 0.09, 0.88)
    style.border_width_left = 2
    style.border_width_right = 2
    style.border_width_top = 2
    style.border_width_bottom = 2
    style.border_color = Color(1.0, 0.25, 0.08, 0.9)
    style.corner_radius_top_left = 10
    style.corner_radius_top_right = 10
    style.corner_radius_bottom_left = 10
    style.corner_radius_bottom_right = 10
    button.add_theme_stylebox_override("normal", style)
    button.anchor_top = 1.0
    button.anchor_bottom = 1.0
    if action == "left" or action == "right":
        button.anchor_left = 0.0
        button.anchor_right = 0.0
        var x = 24.0 if action == "left" else 120.0
        button.offset_left = x
        button.offset_right = x + dimensions.x
        button.offset_top = -112
        button.offset_bottom = -36
    else:
        button.anchor_left = 1.0
        button.anchor_right = 1.0
        var x = -208.0 if action == "brake" else -112.0
        var y = -198.0 if action == "nitro" else -112.0
        button.offset_left = x
        button.offset_right = x + dimensions.x
        button.offset_top = y
        button.offset_bottom = y + dimensions.y
    layer.add_child(button)
    if action == "left":
        button.button_down.connect(func(): left_down = true)
        button.button_up.connect(func(): left_down = false)
    elif action == "right":
        button.button_down.connect(func(): right_down = true)
        button.button_up.connect(func(): right_down = false)
    elif action == "gas":
        button.button_down.connect(func(): gas_down = true)
        button.button_up.connect(func(): gas_down = false)
    elif action == "brake":
        button.button_down.connect(func(): brake_down = true)
        button.button_up.connect(func(): brake_down = false)
    elif action == "nitro":
        button.button_down.connect(func(): nitro_down = true)
        button.button_up.connect(func(): nitro_down = false)

func _move_road(delta: float) -> void:
    # Road markings are a simple looping visual illusion for this first prototype.
    for child in get_children():
        if child is MeshInstance3D and child.position.z < -195.0:
            child.position.z += 210.0

func _make_box(size: Vector3, pos: Vector3, color: Color, parent: Node = null) -> MeshInstance3D:
    var target = self if parent == null else parent
    var mesh = BoxMesh.new()
    mesh.size = size
    var item = MeshInstance3D.new()
    item.mesh = mesh
    item.position = pos
    var mat = StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.38
    mat.metallic = 0.22 if color.r > 0.5 else 0.08
    item.material_override = mat
    target.add_child(item)
    return item
