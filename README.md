## Apply local config

Install fish 
`salt-call --local --file-root salt state.apply common.fish pillar='{"users": {"user1":1} }'`
