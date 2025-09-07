#!/bin/bash

# Vision IQ Screenshot Helper Script
# This script helps you organize and rename screenshots for the README

echo "🔍 Vision IQ Screenshot Helper"
echo "================================"
echo ""

# Create screenshots directory if it doesn't exist
mkdir -p screenshots

echo "📸 Screenshot Organization Guide:"
echo ""
echo "1. Take screenshots of your app on the following screens:"
echo "   - Home/Dashboard screen"
echo "   - Background Verification screen"
echo "   - Analysis Results screen"
echo "   - Demo mode screen"
echo ""
echo "2. Move your screenshot files to the 'screenshots' folder"
echo ""
echo "3. Rename them to match these exact names:"
echo "   - home_screen.png"
echo "   - verification_screen.png"
echo "   - results_screen.png"
echo "   - demo_screen.png"
echo ""

# Check if screenshot files exist
echo "📁 Checking current screenshots..."
echo ""

files=("home_screen.png" "verification_screen.png" "results_screen.png" "demo_screen.png")
found=0

for file in "${files[@]}"; do
    if [[ -f "screenshots/$file" ]]; then
        echo "✅ Found: $file"
        found=$((found + 1))
    else
        echo "❌ Missing: $file"
    fi
done

echo ""
echo "📊 Status: $found/4 screenshots ready"

if [[ $found -eq 4 ]]; then
    echo ""
    echo "🎉 All screenshots ready! Your README will display perfectly."
else
    echo ""
    echo "📝 Next steps:"
    echo "   1. Take missing screenshots"
    echo "   2. Save them in the 'screenshots' folder"
    echo "   3. Use the exact filenames shown above"
    echo "   4. Run this script again to verify"
fi

echo ""
echo "💡 Tips:"
echo "   - Use PNG format for best quality"
echo "   - Take screenshots in portrait mode"
echo "   - Ensure text is clearly readable"
echo "   - Show realistic app usage scenarios"
echo ""
echo "🔗 Alternative: Upload to Imgur or GitHub Issues for external hosting"
