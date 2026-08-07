import re

def update_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # We want to replace 'scale' with 'tScale' inside the tooltip functions.
    # To do this safely, we will replace specific sizing multipliers.
    
    # 1. Yearly Investment Section
    if 'yearly_investment_section.dart' in filepath:
        # Inject tScale
        content = re.sub(
            r'(void _drawTooltip\([^)]+\)\s*\{)',
            r'\1\n    final double tScale = scale * 0.75;',
            content
        )
        
        # Replace sizing variables
        content = re.sub(r'final boxWidth = 160\.0 \* scale;', r'final boxWidth = 160.0 * tScale;', content)
        content = re.sub(r'final boxHeight = 94\.0 \* scale;', r'final boxHeight = 94.0 * tScale;', content)
        content = re.sub(r'Radius.circular\(4 \* scale\)', r'Radius.circular(4 * tScale)', content)
        content = re.sub(r'\(6 \* scale\)', r'(6 * tScale)', content)
        content = re.sub(r'\(4 \* scale\)', r'(4 * tScale)', content)
        content = re.sub(r'\(8 \* scale\)', r'(8 * tScale)', content)
        content = re.sub(r'\(28 \* scale\)', r'(28 * tScale)', content)
        content = re.sub(r'\(1 \* scale\)', r'(1 * tScale)', content)
        content = re.sub(r'Radius.circular\(3 \* scale\)', r'Radius.circular(3 * tScale)', content)
        content = re.sub(r'strokeWidth = 0\.5 \* scale', r'strokeWidth = 0.5 * tScale', content)
        content = re.sub(r'strokeWidth = 1\.0 \* scale', r'strokeWidth = 1.0 * tScale', content)
        content = re.sub(r'10 \* scale', r'10 * tScale', content) # fonts
        content = re.sub(r'12\.0 \* scale', r'12.0 * tScale', content) # pads
        
        # We MUST revert pointerTipY and left which rely on scale for absolute positioning.
        content = re.sub(r'final pointerTipY = baseLine - maxBarHeight - \(10 \* tScale\);', r'final pointerTipY = baseLine - maxBarHeight - (10 * scale);', content)
        content = re.sub(r'if \(left < 10 \* tScale\) left = 10 \* scale;', r'if (left < 10 * scale) left = 10 * scale;', content)
        content = re.sub(r'left = size\.width - boxWidth - \(10 \* tScale\);', r'left = size.width - boxWidth - (10 * scale);', content)
        content = re.sub(r'if \(left \+ boxWidth > size\.width - \(10 \* tScale\)\)', r'if (left + boxWidth > size.width - (10 * scale))', content)

    # 2. Monthly Investment Section
    if 'monthly_investment_section.dart' in filepath:
        # Inject tScale
        content = re.sub(
            r'(void _drawValueTooltip\([^)]+\)\s*\{)',
            r'\1\n    final double tScale = scale * 0.75;',
            content
        )
        content = re.sub(
            r'(void _drawExpandedTooltip\([^)]+\)\s*\{)',
            r'\1\n    final double tScale = scale * 0.75;',
            content
        )
        
        # Replace sizing variables
        content = re.sub(r'8\.5 \* scale', r'8.5 * tScale', content)
        content = re.sub(r'7\.5 \* scale', r'7.5 * tScale', content)
        content = re.sub(r'24 \* scale', r'24 * tScale', content)
        content = re.sub(r'35 \* scale', r'35 * tScale', content)
        content = re.sub(r'4 \* scale', r'4 * tScale', content)
        content = re.sub(r'0\.5 \* scale', r'0.5 * tScale', content)
        content = re.sub(r'8 \* scale', r'8 * tScale', content)
        content = re.sub(r'6 \* scale', r'6 * tScale', content)
        content = re.sub(r'145\.0 \* scale', r'145.0 * tScale', content)
        content = re.sub(r'68\.0 \* scale', r'68.0 * tScale', content)
        content = re.sub(r'10 \* scale', r'10 * tScale', content)
        content = re.sub(r'20 \* scale', r'20 * tScale', content)
        content = re.sub(r'12 \* scale', r'12 * tScale', content)
        content = re.sub(r'22 \* scale', r'22 * tScale', content)
        content = re.sub(r'34 \* scale', r'34 * tScale', content)
        content = re.sub(r'3 \* scale', r'3 * tScale', content)
        content = re.sub(r'2 \* scale', r'2 * tScale', content)
        content = re.sub(r'18 \* scale', r'18 * tScale', content)
        
        # Revert pointer positions which must use global scale
        content = re.sub(r'final top = point\.dy - \(35 \* tScale\);', r'final top = point.dy - (35 * scale);', content)
        content = re.sub(r'final top = point\.dy - boxHeight - \(10 \* tScale\);', r'final top = point.dy - boxHeight - (10 * scale);', content)

    with open(filepath, 'w') as f:
        f.write(content)

update_file('lib/features/portfolio_analysis/widgets/portfolio_analysis/discipline_components/yearly_investment_section.dart')
update_file('lib/features/portfolio_analysis/widgets/portfolio_analysis/discipline_components/monthly_investment_section.dart')
