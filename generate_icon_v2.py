from PIL import Image, ImageDraw

# Create a 1024x1024 square icon
size = 1024
image = Image.new('RGB', (size, size), color='#0D3B3F')  # Dark teal background
draw = ImageDraw.Draw(image)

# Cyan/turquoise color from the logo
cyan = '#00D9D9'

center_x = size // 2
center_y = size // 2

# Fork on left side
fork_left = center_x - 150
fork_prong_height = 350
fork_handle_start_y = center_y + 100
prong_width = 45
prong_spacing = 90

# Draw 3 fork prongs
for i in range(3):
    prong_x = fork_left + (i * prong_spacing)
    draw.rectangle([prong_x - prong_width//2, center_y - fork_prong_height, prong_x + prong_width//2, center_y], fill=cyan, width=0)

# Fork connection bar
draw.rectangle([fork_left - 60, center_y - 60, fork_left + 2*prong_spacing + 60, center_y + 20], fill=cyan, width=0)

# Fork handle
handle_width = 50
draw.rectangle([fork_left - handle_width//2, center_y, fork_left + handle_width//2, fork_handle_start_y + 150], fill=cyan, width=0)

# Spoon on right side
spoon_right = center_x + 150
spoon_bowl_radius = 120
spoon_bowl_center_x = spoon_right
spoon_bowl_center_y = center_y - fork_prong_height // 2

# Draw spoon bowl (oval shape)
draw.ellipse([spoon_bowl_center_x - spoon_bowl_radius, spoon_bowl_center_y - spoon_bowl_radius//2, 
              spoon_bowl_center_x + spoon_bowl_radius, spoon_bowl_center_y + spoon_bowl_radius//2], fill=cyan)

# Spoon handle
draw.rectangle([spoon_right - 25, spoon_bowl_center_y, spoon_right + 25, fork_handle_start_y + 150], fill=cyan, width=0)

# Decorative curved lines around the P (the fork/spoon symbol)
# Draw concentric curved lines to create the P shape effect
for r in range(200, 350, 50):
    draw.arc([center_x - r, center_y - r//2, center_x + r, center_y + r//2], 0, 180, fill=cyan, width=30)

# Save the icon
output_path = 'assets/images/app_icon_1024.png'
image.save(output_path)

print(f"✓ App icon created: {output_path}")
