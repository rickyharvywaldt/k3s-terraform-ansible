[server]
%{ for master in masters ~}
${master.name} ansible_host=${master.ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${ssh_private_key}
%{ endfor ~}

[agent]
%{ for worker in workers ~}
${worker.name} ansible_host=${worker.ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${ssh_private_key}
%{ endfor ~}

[k3s_cluster:children]
server
agent

%{ if enable_bastion ~}
[bastion]
${bastion.name} ansible_host=${bastion.ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${ssh_private_key}
%{ endif ~}
