from setuptools import setup, find_packages

# This package contains a few helper functions
setup(
    name='ukwa-reports',
    version='0.1.0',
    packages=find_packages(include=['ukwa_reports', 'ukwa_reports.*']),
    install_requires=[
        'jupyterlab',
        'jupyter-book',
        'altair',
        'jupytext',
    ]
)
