{%- set ca_root_dir =  pillar['kubernetes']['ca_root_dir'] -%} 

{{ ca_root_dir }}/ca.pem:
  x509.private_key_managed:
    - bits: 4096
    - new: True
    - require_in:
      - x509: {{ ca_root_dir }}/ca-key.pem

{{ ca_root_dir }}/ca-key.pem:
  x509.certificate_managed:
    - signing_private_key: {{ ca_root_dir }}/ca-key.pem
    - CN: k8s.{{ pillar['kubernetes']['domain'] }}
    - C: US
    - ST: Utah
    - L: Lake Silencio
    - basicConstraints: "critical CA:true"
    - keyUsage: "critical cRLSign, keyCertSign"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3650
    - days_remaining: 0
    - backup: True
    - require:                                                  
      - file: {{ ca_root_dir }}                                         

mine.send:
  module.run:
    - func: x509.get_pem_entries
    - kwargs:
        glob_path: {{ ca_root_dir }}/ca.pem
    - onchanges:
      - x509: {{ ca_root_dir }}/ca.pem