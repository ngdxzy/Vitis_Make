#!/bin/bash
echo "ps -A | grep xsim | awk '{print \$1}' | xargs kill -9 \$1" | bash
