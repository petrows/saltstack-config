samba:
  id: Samba-julia
  name: JULIA
  workgroup: PETROWS
  shares:
    storage:
      path: /mnt/julia-data/storage
      comment: 'Network disk: Julia'
      rw: True
      user: master
