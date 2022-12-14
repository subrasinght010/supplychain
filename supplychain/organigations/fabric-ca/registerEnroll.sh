#!/bin/bash

function createDeliver() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/deliver.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/deliver.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-deliver --tls.certfiles "${PWD}/organizations/fabric-ca/deliver/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-deliver.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-deliver.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-deliver.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-deliver.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/deliver.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy deliver's CA cert to deliver's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/deliver.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/deliver/ca-cert.pem" "${PWD}/organizations/peerOrganizations/deliver.example.com/msp/tlscacerts/ca.crt"

  # Copy deliver's CA cert to deliver's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/deliver.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/deliver/ca-cert.pem" "${PWD}/organizations/peerOrganizations/deliver.example.com/tlsca/tlsca.deliver.example.com-cert.pem"

  # Copy deliver's CA cert to deliver's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/deliver.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/deliver/ca-cert.pem" "${PWD}/organizations/peerOrganizations/deliver.example.com/ca/ca.deliver.example.com-cert.pem"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-deliver --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/deliver/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-deliver --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/deliver/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-deliver --id.name deliveradmin --id.secret deliveradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/deliver/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-deliver -M "${PWD}/organizations/peerOrganizations/deliver.example.com/peers/peer0.deliver.example.com/msp" --csr.hosts peer0.deliver.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/deliver/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/deliver.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/deliver.example.com/peers/peer0.deliver.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-deliver -M "${PWD}/organizations/peerOrganizations/deliver.example.com/peers/peer0.deliver.example.com/tls" --enrollment.profile tls --csr.hosts peer0.deliver.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/deliver/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/deliver.example.com/peers/peer0.deliver.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/deliver.example.com/peers/peer0.deliver.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/deliver.example.com/peers/peer0.deliver.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/deliver.example.com/peers/peer0.deliver.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/deliver.example.com/peers/peer0.deliver.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/deliver.example.com/peers/peer0.deliver.example.com/tls/server.key"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-deliver -M "${PWD}/organizations/peerOrganizations/deliver.example.com/users/User1@deliver.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/deliver/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/deliver.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/deliver.example.com/users/User1@deliver.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://deliveradmin:deliveradminpw@localhost:7054 --caname ca-deliver -M "${PWD}/organizations/peerOrganizations/deliver.example.com/users/Admin@deliver.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/deliver/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/deliver.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/deliver.example.com/users/Admin@deliver.example.com/msp/config.yaml"
}

function createLibrary() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/library.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/library.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-library --tls.certfiles "${PWD}/organizations/fabric-ca/library/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-library.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-library.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-library.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-library.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/library.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy library's CA cert to library's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/library.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/library/ca-cert.pem" "${PWD}/organizations/peerOrganizations/library.example.com/msp/tlscacerts/ca.crt"

  # Copy library's CA cert to library's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/library.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/library/ca-cert.pem" "${PWD}/organizations/peerOrganizations/library.example.com/tlsca/tlsca.library.example.com-cert.pem"

  # Copy library's CA cert to library's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/library.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/library/ca-cert.pem" "${PWD}/organizations/peerOrganizations/library.example.com/ca/ca.library.example.com-cert.pem"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-library --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/library/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-library --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/library/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-library --id.name libraryadmin --id.secret libraryadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/library/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-library -M "${PWD}/organizations/peerOrganizations/library.example.com/peers/peer0.library.example.com/msp" --csr.hosts peer0.library.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/library/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/library.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/library.example.com/peers/peer0.library.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-library -M "${PWD}/organizations/peerOrganizations/library.example.com/peers/peer0.library.example.com/tls" --enrollment.profile tls --csr.hosts peer0.library.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/library/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/library.example.com/peers/peer0.library.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/library.example.com/peers/peer0.library.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/library.example.com/peers/peer0.library.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/library.example.com/peers/peer0.library.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/library.example.com/peers/peer0.library.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/library.example.com/peers/peer0.library.example.com/tls/server.key"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-library -M "${PWD}/organizations/peerOrganizations/library.example.com/users/User1@library.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/library/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/library.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/library.example.com/users/User1@library.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://libraryadmin:libraryadminpw@localhost:8054 --caname ca-library -M "${PWD}/organizations/peerOrganizations/library.example.com/users/Admin@library.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/library/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/library.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/library.example.com/users/Admin@library.example.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  # Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp" --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls" --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"

  # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
}

function createProducer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/producer.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/producer.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:6054 --caname ca-producer --tls.certfiles "${PWD}/organizations/fabric-ca/producer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-producer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-producer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-producer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-producer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/producer.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy producer's CA cert to producer's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/producer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/producer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/producer.example.com/msp/tlscacerts/ca.crt"

  # Copy producer's CA cert to producer's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/producer.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/producer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/producer.example.com/tlsca/tlsca.producer.example.com-cert.pem"

  # Copy producer's CA cert to producer's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/producer.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/producer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/producer.example.com/ca/ca.producer.example.com-cert.pem"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-producer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/producer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-producer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/producer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-producer --id.name produceradmin --id.secret produceradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/producer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:6054 --caname ca-producer -M "${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/msp" --csr.hosts peer0.producer.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/producer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/producer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:6054 --caname ca-producer -M "${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls" --enrollment.profile tls --csr.hosts peer0.producer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/producer/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls/server.key"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:6054 --caname ca-producer -M "${PWD}/organizations/peerOrganizations/producer.example.com/users/User1@producer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/producer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/producer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/producer.example.com/users/User1@producer.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://produceradmin:produceradminpw@localhost:6054 --caname ca-producer -M "${PWD}/organizations/peerOrganizations/producer.example.com/users/Admin@producer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/producer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/producer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/producer.example.com/users/Admin@producer.example.com/msp/config.yaml"
}
