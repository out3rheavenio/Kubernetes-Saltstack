{%- set ca_root_dir =  pillar['kubernetes']['ca_root_dir'] -%} 
{{ ca_root_dir}}:
  file.directory

/etc/pki/issued_certs:
  file.directory

salt-minion:
  service.running:
    - enable: True
    - listen:
      - file: /etc/salt/minion.d/signing_policies.conf

/etc/salt/minion.d/signing_policies.conf:
  file.managed:
    - template: jinja
    - source: salt:///certs/signing_policies.conf

## Token & Auth Policy
{{ ca_root_dir }}/token.csv:
  file.managed:
    - source:  salt://certs/token.csv
    - template: jinja
    - group: root
    - mode: 600

include:
    - .ca

{{ ca_root_dir }}/kubernetes.pem:
  x509.certificate_managed:
    - ca_server: ca
    - signing_policy: kube-certs
    - public_key: {{ ca_root_dir }}/www.key
    - CN: kube-master
    - days_remaining: 30
    - backup: True
    - managed_private_key:
        name: {{ ca_root_dir }}/kubernetes-key.pem
        bits: 4096
        backup: True