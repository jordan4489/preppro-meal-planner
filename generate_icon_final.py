from PIL import Image, ImageDraw

# Create a 1024x1024 square icon with professional design
size = 1024
image = Image.new('RGB', (size, size), color='#0D3B3F')  # Dark teal
draw = ImageDraw.Draw(image)

cyan = '#00D9D9'
center = size // 2
stroke_width = 35

# Draw clean fork on left
fork_x = center - 200
fork_top = center - 280
fork_bottom = center + 200

# Fork prongs (3 simple lines)
prong_width = 30
prong_spacing = 100

for i in range(3):
    x = fork_x - 100 + (i * prong_spacing)
    draw.rectangle([x - prong_width//2, fork_top, x + prong_width//2, fork_bottom - 100], fill=cyan)

# Fork connection
draw.rectangle([fork_x - 150, fork_bottom - 130, fork_x + 200, fork_bottom - 80], fill=cyan)

# Fork handle
handle_width = 45
draw.rectangle([fork_x - handle_width//2, fork_bottom - 100, fork_x + handle_width//2, fork_bottom + 200], fill=cyan)

# Draw clean spoon on right
spoon_x = center + 200
spoon_top = center - 280
spoon_bottom = center + 200

# Spoon bowl (oval)
bowl_radius = 90
draw.ellipse([spoon_x - bowl_radius, spoon_top, spoon_x + bowl_radius, spoon_top + 160], fill=cyan)

# Spoon handle
draw.rectangle([spoon_x - 30, spoon_top + 160, spoon_x + 30, spoon_bottom + 200], fill=cyan)

# Save
output_path = 'assets/images/app_icon_1024.png'
image.save(output_path)

print(f"✓ Professional app icon created: {output_path}")
