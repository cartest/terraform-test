# terraform-bootstrap
Environment Bootstrap terraform module

Creates:
   * A VPC
   * DHCP Options
   * A public route table
   * An internet gateway
   * A flow log (to be used as output or remote state into cwles)
   * A Jenkins slave microservice
   * A Route53 Private Hosted Zone
   * VPC Peering connections
