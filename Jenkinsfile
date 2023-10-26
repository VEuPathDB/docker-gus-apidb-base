#!groovy

@Library('pipelib@github-creds')
import org.veupathdb.lib.Builder

node('centos8') {
  sh "env"

  def builder = new Builder(this)

  checkout scm

  builder.buildContainers([
    [ name: 'gus-apidb-base' ],
  ])
}
