from PIL import Image

# Create a placeholder font.png (256x256, 8-bit grayscale)
font = Image.new('L', (256, 320), color=255)  # 'L' mode for 8-bit grayscale
font.save('./skin/font.png')

# Create a placeholder selector.png (128x128, 8-bit grayscale)
selector = Image.new('L', (16, 20), color=255)
selector.save('./skin/selector.png')