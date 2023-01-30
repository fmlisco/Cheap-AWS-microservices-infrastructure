variable "vpc" {
  type = object({
    name                 = string
    cidr_block           = string
    azs                  = list(string)
    private_subnets      = list(string)
    public_subnets       = list(string)
    enable_nat_gateway   = bool
    enable_vpn_gateway   = bool
    enable_dns_hostnames = bool

    public_subnet_tags  = map(any)
    private_subnet_tags = map(any)
  })
}

variable "tags" {
  type = map(any)
}