from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open("zero_trust_framework/version.py", "r", encoding="utf-8") as fh:
    version = {}
    exec(fh.read(), version)
    version = version["__version__"]

setup(
    name="zero-trust-security-framework",
    version=version,
    author="Claude Code Team",
    author_email="security@claude-code.org",
    description="Zero-trust security framework for Claude Code",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/anthropics/claude-code/zero-trust-framework",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Topic :: Security",
        "Topic :: Software Development :: Libraries :: Python Modules",
    ],
    python_requires=">=3.8",
    install_requires=[
        # Minimal dependencies for core functionality
    ],
    extras_require={
        "dev": [
            "pytest>=6.2.5",
            "pytest-cov>=3.0.0",
            "pytest-asyncio>=0.16.0",
            "coverage>=6.2",
            "black>=21.12b0",
            "flake8>=4.0.1",
        ],
        "docs": [
            "sphinx>=4.3.2",
            "sphinx-rtd-theme>=1.0.0",
        ],
        "verification": [
            # Coq integration would be system-level, not pip-installable
        ]
    },
    entry_points={
        "console_scripts": [
            "zero-trust-hook=zero_trust_framework.hooks:main",
            "zero-trust-verify=zero_trust_framework.verification:demo_verification",
        ],
    },
)