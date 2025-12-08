#!/usr/bin/env python3
"""
Swift Code Coverage HTML Report Generator

Generates an interactive HTML report from Swift code coverage data.
Works with any Swift package.

Usage:
    python3 generate_html_coverage.py <package_path> [options]
    
    package_path: Path to the Swift package directory (required)
    
Options:
    --filter <pattern>    Only analyze files matching this pattern
    --output <path>       Output HTML file path (default: coverage_report.html in package dir)
    --help               Show this help message

Examples:
    python3 generate_html_coverage.py ios/Packages/Troop900Application
    python3 generate_html_coverage.py ios/Packages/Troop900Domain --filter "Entities"
    python3 generate_html_coverage.py ios/Packages/Troop900Application --output reports/app_coverage.html
"""

import json
import sys
import argparse
from pathlib import Path
from collections import defaultdict
from typing import Dict, Optional

def load_coverage_data(coverage_path: str) -> dict:
    """Load the JSON coverage data file."""
    try:
        with open(coverage_path, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Error: Coverage data not found at {coverage_path}")
        print("Make sure to run 'swift test --enable-code-coverage' first")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in coverage data: {e}")
        sys.exit(1)

def analyze_segments(segments):
    """Analyze coverage segments."""
    if not segments:
        return 0, 0, 0, 0
    
    lines = {}
    branches = []
    
    for segment in segments:
        line = segment[0]
        col = segment[1]
        count = segment[2]
        is_region = segment[3]
        has_count = segment[4]
        
        if line not in lines:
            lines[line] = count > 0
        else:
            lines[line] = lines[line] or (count > 0)
        
        if is_region and has_count:
            branches.append(count > 0)
    
    covered_lines = sum(1 for covered in lines.values() if covered)
    total_lines = len(lines)
    covered_branches = sum(1 for covered in branches if covered)
    total_branches = len(branches)
    
    return covered_lines, total_lines, covered_branches, total_branches

def analyze_file_coverage(coverage_data: dict, package_name: str, filter_pattern: Optional[str] = None):
    """Analyze coverage data for files in the package."""
    results = {}
    
    data = coverage_data.get('data', [])
    
    for file_entry in data:
        for file_data in file_entry.get('files', []):
            filename = file_data.get('filename', '')
            
            if f'/Sources/{package_name}/' not in filename:
                continue
            
            if filter_pattern and filter_pattern not in filename:
                continue
            
            parts = filename.split(f'/Sources/{package_name}/')
            if len(parts) == 2:
                relative_path = parts[1]
                path_parts = relative_path.split('/')
                
                category = path_parts[0] if len(path_parts) > 1 else 'Root'
                file_name = Path(filename).stem
                
                segments = file_data.get('segments', [])
                covered_lines, total_lines, covered_branches, total_branches = analyze_segments(segments)
                
                line_pct = (covered_lines / total_lines * 100) if total_lines > 0 else 100.0
                branch_pct = (covered_branches / total_branches * 100) if total_branches > 0 else 100.0
                
                if total_lines > 0 and total_branches > 0:
                    overall_pct = (line_pct * 0.5 + branch_pct * 0.5)
                elif total_lines > 0:
                    overall_pct = line_pct
                elif total_branches > 0:
                    overall_pct = branch_pct
                else:
                    overall_pct = 100.0
                
                uncovered_regions = []
                for segment in segments:
                    line = segment[0]
                    col = segment[1]
                    count = segment[2]
                    is_region = segment[3]
                    has_count = segment[4]
                    
                    if is_region and has_count and count == 0:
                        uncovered_regions.append({'line': line, 'column': col})
                
                results[filename] = {
                    'category': category,
                    'name': file_name,
                    'relative_path': relative_path,
                    'line_coverage': {
                        'covered': covered_lines,
                        'total': total_lines,
                        'percentage': line_pct
                    },
                    'branch_coverage': {
                        'covered': covered_branches,
                        'total': total_branches,
                        'percentage': branch_pct
                    },
                    'overall_percentage': overall_pct,
                    'uncovered_regions': uncovered_regions
                }
    
    return results

def generate_html_report(coverage_stats, package_name: str, filter_pattern: Optional[str]):
    """Generate an interactive HTML report."""
    
    # Group by category
    by_category = defaultdict(list)
    for filepath, stats in coverage_stats.items():
        by_category[stats['category']].append((filepath, stats))
    
    # Calculate overall statistics
    total_lines_covered = sum(s['line_coverage']['covered'] for s in coverage_stats.values())
    total_lines = sum(s['line_coverage']['total'] for s in coverage_stats.values())
    total_branches_covered = sum(s['branch_coverage']['covered'] for s in coverage_stats.values())
    total_branches = sum(s['branch_coverage']['total'] for s in coverage_stats.values())
    
    overall_line_pct = (total_lines_covered / total_lines * 100) if total_lines > 0 else 0.0
    overall_branch_pct = (total_branches_covered / total_branches * 100) if total_branches > 0 else 0.0
    overall_pct = (overall_line_pct * 0.5 + overall_branch_pct * 0.5)
    
    filter_info = f" (Filtered: {filter_pattern})" if filter_pattern else ""
    
    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Code Coverage Report - {package_name}</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: #f5f5f7;
            color: #1d1d1f;
            line-height: 1.6;
        }}
        
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }}
        
        header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 20px;
            margin-bottom: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }}
        
        h1 {{
            font-size: 2.5em;
            margin-bottom: 10px;
            font-weight: 600;
        }}
        
        .subtitle {{
            font-size: 1.1em;
            opacity: 0.9;
        }}
        
        .stats-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }}
        
        .stat-card {{
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }}
        
        .stat-card:hover {{
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }}
        
        .stat-label {{
            font-size: 0.9em;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }}
        
        .stat-value {{
            font-size: 2.5em;
            font-weight: 700;
            margin-bottom: 8px;
        }}
        
        .stat-detail {{
            font-size: 0.9em;
            color: #666;
        }}
        
        .category-section {{
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            overflow: hidden;
        }}
        
        .category-header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }}
        
        .category-header:hover {{
            background: linear-gradient(135deg, #5568d3 0%, #654b8f 100%);
        }}
        
        .category-name {{
            font-size: 1.3em;
            font-weight: 600;
        }}
        
        .category-stats {{
            font-size: 0.9em;
            opacity: 0.9;
        }}
        
        .category-content {{
            display: none;
            padding: 20px;
        }}
        
        .category-content.active {{
            display: block;
        }}
        
        .file-item {{
            border-left: 4px solid #667eea;
            padding: 15px;
            margin-bottom: 15px;
            background: #f9f9fb;
            border-radius: 6px;
        }}
        
        .file-item.perfect {{ border-left-color: #34c759; }}
        .file-item.excellent {{ border-left-color: #30d158; }}
        .file-item.good {{ border-left-color: #ffd60a; }}
        .file-item.fair {{ border-left-color: #ff9f0a; }}
        .file-item.poor {{ border-left-color: #ff3b30; }}
        
        .file-name {{
            font-size: 1.1em;
            font-weight: 600;
            margin-bottom: 5px;
            display: flex;
            align-items: center;
            gap: 10px;
        }}
        
        .file-path {{
            font-size: 0.85em;
            color: #666;
            font-family: 'Monaco', 'Courier New', monospace;
            margin-bottom: 10px;
        }}
        
        .coverage-badge {{
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 600;
            color: white;
        }}
        
        .coverage-badge.perfect {{ background: #34c759; }}
        .coverage-badge.excellent {{ background: #30d158; }}
        .coverage-badge.good {{ background: #ffd60a; color: #000; }}
        .coverage-badge.fair {{ background: #ff9f0a; }}
        .coverage-badge.poor {{ background: #ff3b30; }}
        
        .coverage-details {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 10px;
            margin-top: 10px;
        }}
        
        .coverage-metric {{
            font-size: 0.9em;
            color: #666;
        }}
        
        .coverage-bar {{
            height: 8px;
            background: #e5e5e7;
            border-radius: 4px;
            overflow: hidden;
            margin-top: 5px;
        }}
        
        .coverage-bar-fill {{
            height: 100%;
            transition: width 0.3s ease;
        }}
        
        .coverage-bar-fill.perfect {{ background: #34c759; }}
        .coverage-bar-fill.excellent {{ background: #30d158; }}
        .coverage-bar-fill.good {{ background: #ffd60a; }}
        .coverage-bar-fill.fair {{ background: #ff9f0a; }}
        .coverage-bar-fill.poor {{ background: #ff3b30; }}
        
        .uncovered-regions {{
            margin-top: 10px;
            padding: 10px;
            background: #fff3cd;
            border-left: 3px solid #ffc107;
            border-radius: 4px;
        }}
        
        .uncovered-title {{
            font-weight: 600;
            margin-bottom: 5px;
            color: #856404;
        }}
        
        .uncovered-list {{
            font-size: 0.9em;
            color: #856404;
            font-family: 'Monaco', 'Courier New', monospace;
        }}
        
        .filter-buttons {{
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }}
        
        .filter-btn {{
            padding: 10px 20px;
            border: none;
            border-radius: 20px;
            background: white;
            color: #667eea;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        
        .filter-btn:hover {{
            background: #667eea;
            color: white;
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }}
        
        .filter-btn.active {{
            background: #667eea;
            color: white;
        }}
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>📊 Code Coverage Report</h1>
            <div class="subtitle">{package_name}{filter_info}</div>
        </header>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Overall Coverage</div>
                <div class="stat-value" style="color: {'#34c759' if overall_pct >= 95 else '#ffd60a' if overall_pct >= 85 else '#ff9f0a'}">{overall_pct:.1f}%</div>
                <div class="stat-detail">Combined line & branch coverage</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Line Coverage</div>
                <div class="stat-value">{overall_line_pct:.1f}%</div>
                <div class="stat-detail">{total_lines_covered}/{total_lines} lines</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Branch Coverage</div>
                <div class="stat-value">{overall_branch_pct:.1f}%</div>
                <div class="stat-detail">{total_branches_covered}/{total_branches} branches</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Files</div>
                <div class="stat-value">{len(coverage_stats)}</div>
                <div class="stat-detail">Total analyzed</div>
            </div>
        </div>
        
        <div class="filter-buttons">
            <button class="filter-btn active" onclick="filterByLevel('all')">All Files</button>
            <button class="filter-btn" onclick="filterByLevel('perfect')">🎯 Perfect (100%)</button>
            <button class="filter-btn" onclick="filterByLevel('excellent')">✅ Excellent (95%+)</button>
            <button class="filter-btn" onclick="filterByLevel('good')">👍 Good (85-95%)</button>
            <button class="filter-btn" onclick="filterByLevel('fair')">⚠️ Fair (70-85%)</button>
            <button class="filter-btn" onclick="filterByLevel('poor')">🔴 Poor (<70%)</button>
        </div>
"""
    
    # Add each category section
    for category in sorted(by_category.keys()):
        files = sorted(by_category[category], key=lambda x: x[1]['name'])
        
        # Calculate category stats
        cat_lines_covered = sum(s['line_coverage']['covered'] for _, s in files)
        cat_lines_total = sum(s['line_coverage']['total'] for _, s in files)
        cat_branches_covered = sum(s['branch_coverage']['covered'] for _, s in files)
        cat_branches_total = sum(s['branch_coverage']['total'] for _, s in files)
        
        cat_line_pct = (cat_lines_covered / cat_lines_total * 100) if cat_lines_total > 0 else 0.0
        cat_branch_pct = (cat_branches_covered / cat_branches_total * 100) if cat_branches_total > 0 else 0.0
        cat_overall = (cat_line_pct * 0.5 + cat_branch_pct * 0.5)
        
        html += f"""
        <div class="category-section">
            <div class="category-header" onclick="toggleCategory(this)">
                <div class="category-name">{category}</div>
                <div class="category-stats">{len(files)} files | {cat_overall:.1f}% coverage</div>
            </div>
            <div class="category-content active">
"""
        
        for filepath, stats in files:
            pct = stats['overall_percentage']
            if pct == 100:
                level = 'perfect'
            elif pct >= 95:
                level = 'excellent'
            elif pct >= 85:
                level = 'good'
            elif pct >= 70:
                level = 'fair'
            else:
                level = 'poor'
            
            html += f"""
                <div class="file-item {level}" data-level="{level}">
                    <div class="file-name">
                        {stats['name']}
                        <span class="coverage-badge {level}">{pct:.1f}%</span>
                    </div>
                    <div class="file-path">{stats['relative_path']}</div>
                    <div class="coverage-details">
                        <div>
                            <div class="coverage-metric">
                                Line Coverage: {stats['line_coverage']['covered']}/{stats['line_coverage']['total']} ({stats['line_coverage']['percentage']:.1f}%)
                            </div>
                            <div class="coverage-bar">
                                <div class="coverage-bar-fill {level}" style="width: {stats['line_coverage']['percentage']}%"></div>
                            </div>
                        </div>
                        <div>
                            <div class="coverage-metric">
                                Branch Coverage: {stats['branch_coverage']['covered']}/{stats['branch_coverage']['total']} ({stats['branch_coverage']['percentage']:.1f}%)
                            </div>
                            <div class="coverage-bar">
                                <div class="coverage-bar-fill {level}" style="width: {stats['branch_coverage']['percentage']}%"></div>
                            </div>
                        </div>
                    </div>
"""
            
            if stats['uncovered_regions']:
                html += f"""
                    <div class="uncovered-regions">
                        <div class="uncovered-title">⚠️ {len(stats['uncovered_regions'])} Uncovered Region(s):</div>
                        <div class="uncovered-list">
"""
                for i, region in enumerate(stats['uncovered_regions'][:10]):
                    html += f"Line {region['line']}, Col {region['column']}<br>"
                
                if len(stats['uncovered_regions']) > 10:
                    html += f"... and {len(stats['uncovered_regions']) - 10} more"
                
                html += """
                        </div>
                    </div>
"""
            
            html += """
                </div>
"""
        
        html += """
            </div>
        </div>
"""
    
    html += """
    </div>
    
    <script>
        function toggleCategory(header) {
            const content = header.nextElementSibling;
            content.classList.toggle('active');
        }
        
        function filterByLevel(level) {
            document.querySelectorAll('.filter-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            event.target.classList.add('active');
            
            document.querySelectorAll('.file-item').forEach(item => {
                if (level === 'all' || item.dataset.level === level) {
                    item.style.display = 'block';
                } else {
                    item.style.display = 'none';
                }
            });
            
            document.querySelectorAll('.category-section').forEach(section => {
                const hasVisibleItems = level === 'all' || 
                    Array.from(section.querySelectorAll('.file-item')).some(item => 
                        item.style.display !== 'none' && item.dataset.level === level
                    );
                
                section.style.display = hasVisibleItems ? 'block' : 'none';
            });
        }
    </script>
</body>
</html>
"""
    
    return html

def find_coverage_file(package_path: Path) -> Optional[Path]:
    """Find the coverage JSON file for a package."""
    build_dirs = [
        package_path / '.build' / 'arm64-apple-macosx' / 'debug' / 'codecov',
        package_path / '.build' / 'x86_64-apple-macosx' / 'debug' / 'codecov',
        package_path / '.build' / 'debug' / 'codecov',
    ]
    
    package_name = package_path.name
    
    for build_dir in build_dirs:
        if build_dir.exists():
            coverage_file = build_dir / f'{package_name}.json'
            if coverage_file.exists():
                return coverage_file
            json_files = list(build_dir.glob('*.json'))
            if json_files:
                return json_files[0]
    
    return None

def main():
    parser = argparse.ArgumentParser(
        description='Generate interactive HTML coverage report for Swift packages',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    parser.add_argument('package_path', help='Path to the Swift package directory')
    parser.add_argument('--filter', help='Only analyze files matching this pattern')
    parser.add_argument('--output', help='Output HTML file path (default: coverage_report.html in package dir)')
    
    args = parser.parse_args()
    
    package_path = Path(args.package_path).resolve()
    if not package_path.exists():
        print(f"Error: Package path does not exist: {package_path}")
        sys.exit(1)
    
    package_name = package_path.name
    
    print(f"Looking for coverage data for {package_name}...")
    coverage_file = find_coverage_file(package_path)
    
    if not coverage_file:
        print(f"\nError: Coverage data not found for {package_name}")
        print(f"Expected location: {package_path}/.build/.../codecov/{package_name}.json")
        print("\nPlease run tests with coverage enabled first:")
        print(f"  cd {package_path}")
        print(f"  swift test --enable-code-coverage")
        sys.exit(1)
    
    print(f"Found coverage data: {coverage_file}")
    print("Loading coverage data...")
    coverage_data = load_coverage_data(str(coverage_file))
    
    print(f"Analyzing coverage for {package_name}...")
    if args.filter:
        print(f"Filtering files containing: '{args.filter}'")
    
    coverage_stats = analyze_file_coverage(coverage_data, package_name, args.filter)
    
    print(f"Found {len(coverage_stats)} files")
    print("Generating HTML report...")
    html_report = generate_html_report(coverage_stats, package_name, args.filter)
    
    if args.output:
        output_path = Path(args.output)
    else:
        output_path = package_path / 'coverage_report.html'
    
    with open(output_path, 'w') as f:
        f.write(html_report)
    
    print(f"\n✅ Interactive HTML report generated: {output_path}")
    print(f"   Open this file in your browser to view the interactive coverage report.")

if __name__ == '__main__':
    main()
