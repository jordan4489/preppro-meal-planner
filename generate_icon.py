from PIL import Image, ImageDraw

# Create a 1024x1024 square icon
size = 1024
image = Image.new('RGB', (size, size), color='#2090D0')  # PrepPro blue
draw = ImageDraw.Draw(image)

# Draw a white fork (meal/food icon)
# Fork handle (vertical line on left)
fork_x = size // 3
fork_top = size // 4
fork_bottom = 3 * size // 4
fork_width = 60

# Handle - thick white rectangle
draw.rectangle([fork_x - fork_width//2, fork_bottom - 200, fork_x + fork_width//2, fork_bottom], fill='white')

# Fork prongs (3 vertical lines at top)
prong_width = 40
prong_height = size // 2
prong_spacing = 80
start_x = fork_x - 100

for i in range(3):
    prong_x = start_x + (i * prong_spacing)
    draw.rectangle([prong_x - prong_width//2, fork_top, prong_x + prong_width//2, fork_top + prong_height], fill='white')

# Fork connection (horizontal bar connecting prongs to handle)
draw.rectangle([start_x - prong_width//2 - 20, fork_top + prong_height - 50, start_x + 2*prong_spacing + prong_width//2 + 20, fork_top + prong_height + 50], fill='white')

# Save the icon
output_path = 'assets/images/app_icon_1024.png'
image.save(output_path)

print(f"✓ App icon created: {output_path}")

