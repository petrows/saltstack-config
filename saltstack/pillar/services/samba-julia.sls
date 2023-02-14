samba:
  id: Samba
  name: JULIA
  workgroup: PETROWS
  shares:
    storage:
      path: /srv/julia-data/storage
      comment: 'Network disk: Julia'
      rw: True
      user: master
