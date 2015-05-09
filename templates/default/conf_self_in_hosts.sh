grep -q "^$(hostname -I)" /etc/hosts && sed -i "s/^$(hostname -I).*/$(hostname -I) $(hostname)/" /etc/hosts || echo "$(hostname -I) $(hostname)" >> /etc/hosts
