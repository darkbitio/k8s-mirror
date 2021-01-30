#!/usr/bin/env ruby

require 'json'
require 'yaml'
require 'pry'

def run_insert(input, insert_path)
  result = IO.popen("etcdctl put #{insert_path}", 'r+') do |io|
    io.write(input)
    io.close_write
    io.read
  end
  result
end

def parse_line(line)
  json = JSON.parse(line)
  namespace_name = json.dig('resource','data','metadata','namespace') || "unknown"
  resource_name = json.dig('resource','data','metadata','name') || "unknown"
  resource = json.dig('resource','data').to_json

  case json.dig('asset_type')
  when "k8s.io/Node"
    run_insert(resource, "/registry/minions/#{resource_name}")
  when "k8s.io/Pod"
    run_insert(resource, "/registry/pods/#{namespace_name}/#{resource_name}")
  when "k8s.io/ComponentStatus"
    run_insert(resource, "/registry/componentstatuses/#{resource_name}")
  when "k8s.io/CSINode"
    run_insert(resource, "/registry/csinodes/#{resource_name}")
  when "k8s.io/ClusterRoleBinding"
    run_insert(resource, "/registry/clusterrolebindings/#{resource_name}")
  when "k8s.io/ClusterRole"
    run_insert(resource, "/registry/clusterroles/#{resource_name}")
  when "k8s.io/RoleBinding"
    run_insert(resource, "/registry/rolebindings/#{namespace_name}/#{resource_name}")
  when "k8s.io/Role"
    run_insert(resource, "/registry/roles/#{namespace_name}/#{resource_name}")
  when "k8s.io/Secret"
    run_insert(resource, "/registry/secrets/#{namespace_name}/#{resource_name}")
  when "k8s.io/ServiceAccount"
    run_insert(resource, "/registry/serviceaccounts/#{namespace_name}/#{resource_name}")
  when "k8s.io/Service"
    run_insert(resource, "/registry/services/specs/#{namespace_name}/#{resource_name}")
  when "k8s.io/Endpoints"
    run_insert(resource, "/registry/services/endpoints/#{namespace_name}/#{resource_name}")
  when "k8s.io/Event"
    run_insert(resource, "/registry/events/#{namespace_name}/#{resource_name}")
  when "k8s.io/ConfigMap"
    run_insert(resource, "/registry/configmaps/#{namespace_name}/#{resource_name}")
  when "k8s.io/EndpointSlice"
    run_insert(resource, "/registry/endpointslices/#{namespace_name}/#{resource_name}")
  when "k8s.io/Namespace"
    run_insert(resource, "/registry/namespaces/#{resource_name}")
  when "k8s.io/StorageClass"
    run_insert(resource, "/registry/storageclasses/#{resource_name}")
  when "k8s.io/APIService"
    run_insert(resource, "/registry/apiregistration.k8s.io/apiservices/#{resource_name}")
  when "k8s.io/PriorityClass"
    run_insert(resource, "/registry/priorityclasses/#{resource_name}")
  when "k8s.io/Lease"
    run_insert(resource, "/registry/masterleases/#{resource_name}")
  when "k8s.io/Version"
    # skip
  else
    puts "Skipping: #{line.to_s[0, 50]}" 
  end
end

def parse_input_file(file)
  IO.foreach(file) do |line|
    if JSON.parse(line)
      parse_line(line)
    else
      puts "ERROR parsing: #{line.to_s}"
      puts "EXITING"
      exit 1
    end
  end
end

if ARGV.empty?
  puts "No input file passed as first argument. Exiting."
  exit 1
else
  parse_input_file(ARGV[0])
end
