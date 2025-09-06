#!/usr/bin/env node

/**
 * AI Language Detection Tool
 * Scans text for AI-generated marketing language and buzzwords
 */

const fs = require('fs');
const path = require('path');

const HIGH_ALERT_WORDS = [
    'comprehensive', 'complete', 'total', 'ultimate', 'full', 'entire', 'absolute', 
    'definitive', 'revolutionary', 'groundbreaking', 'innovative', 'cutting-edge', 
    'state-of-the-art', 'world-class', 'robust', 'sophisticated', 'advanced', 
    'powerful', 'seamless', 'elegant', 'efficient', 'optimal', 'amazing', 
    'fantastic', 'incredible', 'awesome', 'brilliant', 'excellent', 'perfect', 
    'wonderful', 'outstanding', 'remarkable', 'extraordinary', 'impressive', 
    'stunning', 'magnificent', 'superb', 'terrific', 'marvelous', 'phenomenal', 
    'spectacular', 'fabulous'
];

const MEDIUM_ALERT_WORDS = [
    'enterprise-grade', 'production-ready', 'scalable', 'extensible', 'modular', 
    'flexible', 'intuitive', 'user-friendly', 'next-generation', 'best-in-class', 
    'industry-leading', 'game-changing', 'provides', 'enables', 'delivers', 
    'offers', 'ensures', 'facilitates'
];

const AI_PATTERNS = [
    /will definitely/gi,
    /always works/gi,
    /never fails/gi,
    /guaranteed to/gi,
    /perfectly handles/gi,
    /I'll help you/gi,
    /let me create/gi,
    /I've generated/gi,
    /here's a comprehensive/gi
];

function detectAILanguage(text, filename = '') {
    let score = 0;
    let flags = [];
    
    // Check high alert words
    for (const word of HIGH_ALERT_WORDS) {
        const regex = new RegExp(`\\b${word}\\b`, 'gi');
        const matches = text.match(regex) || [];
        if (matches.length > 0) {
            score += matches.length * 3;
            flags.push(`"${word}" used ${matches.length} times`);
        }
    }
    
    // Check medium alert words  
    for (const word of MEDIUM_ALERT_WORDS) {
        const regex = new RegExp(`\\b${word}\\b`, 'gi');
        const matches = text.match(regex) || [];
        if (matches.length > 0) {
            score += matches.length * 1;
            flags.push(`"${word}" used ${matches.length} times`);
        }
    }
    
    // Check AI patterns
    for (const pattern of AI_PATTERNS) {
        const matches = text.match(pattern) || [];
        if (matches.length > 0) {
            score += matches.length * 2;
            flags.push(`AI pattern "${matches[0]}" found ${matches.length} times`);
        }
    }
    
    // Special penalties
    const comprehensiveCount = (text.toLowerCase().match(/comprehensive/g) || []).length;
    if (comprehensiveCount > 2) {
        score += 5; // Heavy penalty for overuse
        flags.push(`"comprehensive" overused (${comprehensiveCount} times)`);
    }
    
    let verdict;
    if (score > 8) verdict = '🚨 DEFINITELY AI-GENERATED';
    else if (score > 5) verdict = '⚠️ PROBABLY AI-GENERATED'; 
    else if (score > 2) verdict = '😐 MAYBE AI-GENERATED';
    else verdict = '✅ SOUNDS HUMAN';
    
    return {
        filename,
        score,
        flags,
        verdict,
        recommendation: score > 5 ? 'Rewrite with simpler, more direct language' : 'Looks good'
    };
}

function scanFile(filePath) {
    try {
        const content = fs.readFileSync(filePath, 'utf8');
        const filename = path.basename(filePath);
        return detectAILanguage(content, filename);
    } catch (error) {
        return {
            filename: path.basename(filePath),
            error: error.message
        };
    }
}

function scanDirectory(dirPath, extensions = ['.md', '.js', '.py', '.txt']) {
    const results = [];
    
    function walkDir(dir) {
        const items = fs.readdirSync(dir);
        
        for (const item of items) {
            const fullPath = path.join(dir, item);
            const stat = fs.statSync(fullPath);
            
            if (stat.isDirectory() && !item.startsWith('.') && item !== 'node_modules') {
                walkDir(fullPath);
            } else if (stat.isFile()) {
                const ext = path.extname(item);
                if (extensions.includes(ext)) {
                    results.push(scanFile(fullPath));
                }
            }
        }
    }
    
    walkDir(dirPath);
    return results;
}

function generateReport(results) {
    console.log('🤖 AI Language Detection Report');
    console.log('================================');
    
    const flagged = results.filter(r => r.score > 2);
    const total = results.length;
    
    console.log(`Scanned ${total} files, ${flagged.length} flagged as potentially AI-generated\n`);
    
    // Sort by score descending
    flagged.sort((a, b) => b.score - a.score);
    
    for (const result of flagged) {
        console.log(`${result.verdict} - ${result.filename} (score: ${result.score})`);
        if (result.flags.length > 0) {
            result.flags.forEach(flag => console.log(`  • ${flag}`));
        }
        console.log(`  💡 ${result.recommendation}\n`);
    }
    
    if (flagged.length === 0) {
        console.log('✅ All files passed AI language detection!');
    }
}

// CLI usage
if (require.main === module) {
    const args = process.argv.slice(2);
    
    if (args.length === 0) {
        console.log('Usage:');
        console.log('  node ai-language-detector.js <file>           # Scan single file');
        console.log('  node ai-language-detector.js <directory>      # Scan directory');
        console.log('  echo "text" | node ai-language-detector.js    # Scan from stdin');
        process.exit(1);
    }
    
    const target = args[0];
    
    if (fs.existsSync(target)) {
        const stat = fs.statSync(target);
        
        if (stat.isFile()) {
            const result = scanFile(target);
            console.log(`${result.verdict} - ${result.filename} (score: ${result.score})`);
            if (result.flags.length > 0) {
                result.flags.forEach(flag => console.log(`  • ${flag}`));
            }
            console.log(`💡 ${result.recommendation}`);
        } else if (stat.isDirectory()) {
            const results = scanDirectory(target);
            generateReport(results);
        }
    } else {
        console.error(`Error: ${target} not found`);
        process.exit(1);
    }
}

module.exports = { detectAILanguage, scanFile, scanDirectory };