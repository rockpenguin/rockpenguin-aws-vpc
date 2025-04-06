## TODO

### NAT

- [x] User specified AMI
- [x] User specified instance type
- Create multiple NAT configurations:
  - [ ] Single (simple) NAT instance
  - [ ] Auto Scaling Group
  - [ ] Maybe alterNAT (https://github.com/chime/terraform-aws-alternat)
- [ ] Multi-AZ NAT GW option
- [ ] Make more of the instance config as vars
- [x] Also need IAM instance profile role for SSM access
- [x] EC2 key pair
- [x] enhanced monitoring?

### Subnets

- Allow for autoconfig
  - [ ] Automatic naming based on prv/pub, VPC name, AZid, etc.
  - [ ] Supply only AZs
