# install kafka from helm

```bash
helm install my-kafka ./kafka-14.5.1.tgz --namespace kafka --create-namespace -f values.yaml
```

# add test data before backup

```bash
kafka-console-producer.sh --topic test --broker-list localhost:9092
```

# check test data after restore

```bash
kafka-console-consumer.sh --topic test --bootstrap-server localhost:9092 --from-beginning
```

example:

```bash
kubectl -n kafka exec -it my-kafka-0 bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl kubectl exec [POD] -- [COMMAND] instead.
I have no name!@my-kafka-0:/$ kafka-console-producer.sh --topic test --broker-list localhost:9092
>aaa
[2022-01-05 05:25:22,567] WARN [Producer clientId=console-producer] Error while fetching metadata with correlation id 3 : {test=LEADER_NOT_AVAILABLE} (org.apache.kafka.clients.NetworkClient)
>bbb
>ccc
>ddd
>eee
>^CI have no name!@my-kafka-0:/$ kafka-console-consumer.sh --topic test --bootstrap-server localhost:9092 --from-beginning
aaa
bbb
ccc
ddd
eee
^CProcessed a total of 5 messages
```

