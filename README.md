# Deploying Postgres in AWS


This project provides a comprehensive guide to deploying PostgreSQL on AWS using two fully managed database services: Amazon RDS for PostgreSQL and Amazon Aurora PostgreSQL-Compatible Edition. These services enable developers and organizations to set up, operate, and scale PostgreSQL databases in the cloud with ease, eliminating the need for manual infrastructure management.

Whether you're creating a lightweight development environment for testing or a robust, production-grade backend for mission-critical applications, AWS offers flexible deployment options tailored to diverse needs. 

Each service—Amazon RDS for PostgreSQL and Amazon Aurora PostgreSQL-Compatible Edition—comes with distinct performance characteristics, feature sets, and cost profiles, allowing you to choose the best fit for your use case. Amazon RDS provides a straightforward, managed PostgreSQL experience with automated backups, patching, and scaling, while Aurora offers enhanced performance and high availability through its distributed storage architecture.

As part of this project, we deploy the [Pagila](https://www.postgresql.org/ftp/projects/pgFoundry/dbsamples/pagila/) sample database, a well-known PostgreSQL dataset modeled after a fictional DVD rental store. This allows you to test and explore the functionality of your deployed database in a practical, real-world-inspired scenario.

![diagram](aws-postgres.png)

## What You'll Learn

- The core differences between RDS PostgreSQL and Aurora PostgreSQL
- How to provision each database using Terraform
- The distinction between Aurora readers and RDS read replicas
- Best practices for security, scalability, and infrastructure-as-code deployment

## Comparison of RDS for PostgreSQL and Aurora PostgreSQL

When deploying PostgreSQL on AWS, Amazon RDS for PostgreSQL and Amazon Aurora PostgreSQL-Compatible Edition are two fully managed options. Both simplify database management, but they differ in architecture, performance, and cost. This document compares them to help you choose the right service for your application.

### Overview

- **Amazon RDS for PostgreSQL**: A managed service offering standard PostgreSQL with automated backups, patching, and scaling. Ideal for cost-effective, general-purpose workloads.

- **Amazon Aurora PostgreSQL**: A high-performance, PostgreSQL-compatible engine with distributed storage, designed for scalability and enterprise-grade applications.

## Key Differences

### 1. Architecture and Storage

- **RDS**: Uses standard PostgreSQL with EBS storage. Storage is provisioned manually (up to 64 TB) and scales with potential downtime.
- **Aurora**: Features distributed storage across multiple Availability Zones (AZs), auto-scaling up to 128 TB without downtime.

**Takeaway**: Aurora offers greater scalability and resilience.

### 2. Performance

- **RDS**: Reliable for standard workloads but limited by EBS and single-instance architecture.
- **Aurora**: Delivers up to 5x the throughput of RDS with features like parallel query execution.

**Takeaway**: Aurora excels in high-throughput scenarios.

### 3. High Availability and Replication

- **RDS**: Multi-AZ setups with 60–120 second failover; read replicas use asynchronous replication.
- **Aurora**: Faster failover (<30 seconds), supports up to 15 low-latency read replicas, and offers Aurora Global Database for cross-region replication.

**Takeaway**: Aurora provides better availability and replication options.

### 4. Scalability

- **RDS**: Supports vertical scaling and read replicas; storage scaling may involve downtime.
- **Aurora**: Scales compute and storage seamlessly, with Aurora Serverless for variable workloads.

**Takeaway**: Aurora is more flexible for dynamic scaling.

### 5. Cost

- **RDS**: More affordable for smaller, predictable workloads.
- **Aurora**: Higher cost for enhanced performance; Aurora Serverless can reduce costs for variable usage.

**Takeaway**: RDS is cost-effective; Aurora’s price reflects its advanced features.

### 6. Features and Compatibility

- **RDS**: Full PostgreSQL compatibility with most extensions.
- **Aurora**: PostgreSQL-compatible but may lack some extensions; offers unique features like backtrack and parallel query.

**Takeaway**: RDS prioritizes compatibility; Aurora adds cloud-native features.

### 7. Backup and Recovery

- **RDS**: Automated backups (up to 35 days) and point-in-time recovery; restores can be slow for large databases.
- **Aurora**: Faster backups and restores; backtrack enables quick point-in-time recovery.

**Takeaway**: Aurora offers faster, more flexible recovery.

### 8. Use Cases

- **RDS**: Best for cost-conscious, general-purpose applications or development environments.
- **Aurora**: Ideal for high-performance, mission-critical applications or variable workloads (with Serverless).

**Takeaway**: RDS suits simpler needs; Aurora excels in demanding scenarios.

## Choosing the Right Service

- **Choose RDS if**: You need a cost-effective, fully compatible PostgreSQL solution for standard workloads.
- **Choose Aurora if**: Your application demands high performance, scalability, or advanced features like global replication.


## Prerequisites

* [An AWS Account](https://aws.amazon.com/console/)
* [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) 
* [Install Latest Terraform](https://developer.hashicorp.com/terraform/install)
* [postgres `pqsl` client](https://www.postgresql.org/download/linux/ubuntu/) - `apt install postgresql-client`
* [pgAdmin4 client](https://www.pgadmin.org/download/)

If this is your first time watching our content, we recommend starting with this video: [AWS + Terraform: Easy Setup](https://youtu.be/BCMQo0CB9wk). It provides a step-by-step guide to properly configure Terraform, Packer, and the AWS CLI.

## Download this Repository

```bash
git clone https://github.com/mamonaco1973/aws-postgres.git
cd aws-postgres
```

## Build the Code

Run [check_env](check_env.sh) then run [apply](apply.sh).

```bash
~/aws-postgres$ ./apply.sh
NOTE: Validating that required commands are found in your PATH.
NOTE: aws is found in the current PATH.
NOTE: psql is found in the current PATH.
NOTE: terraform is found in the current PATH.
NOTE: jq is found in the current PATH.
NOTE: All required commands are available.
NOTE: Checking AWS cli connection.
NOTE: Successfully logged into AWS.
NOTE: Building Database Instances.
Initializing the backend...
Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Using previously-installed hashicorp/aws v6.0.0
- Using previously-installed hashicorp/random v3.7.2
Terraform has been successfully initialized!
```
## Build Results

After applying the Terraform scripts, the following AWS resources will be created:

### VPC & Subnets
- Custom VPC: `rds-vpc`
- Two public subnets for database placement:
  - `rds-subnet-1`
  - `rds-subnet-2`
- Internet Gateway: `rds-igw`
- Public route table with default route

### Security Groups
- Security Group: `rds_sg`  
  (Allows access to PostgreSQL)

### Secrets & Credentials
- Secrets Manager entries:
  - `aurora_credentials`
  - `postgres_credentials`
- Secrets stored via `aws_secretsmanager_secret_version`
- Random passwords generated using `random_password` for each engine

### RDS PostgreSQL
- Primary RDS instance: `postgres_rds`
- Read Replica: `postgres_rds_replica`
- Subnet group: `rds_subnet_group`

### Aurora PostgreSQL
- Aurora Cluster: `aurora_cluster`
- Writer instance: `aurora_instance_writer`
- Reader instance: `aurora_instance_reader`
- Subnet group: `aurora_subnet_group`

## pgAdmin4 Demo

![pgadmin](pgadmin.png)

Query 1:
```sql
-- Select the film title and full actor name for each film
SELECT
    f.title AS film_title,                                      -- Get the film's title from the 'film' table
    a.first_name || ' ' || a.last_name AS actor_name            -- Concatenate actor's first and last name as 'actor_name'
FROM
    film f                                                      -- From the 'film' table aliased as 'f'
JOIN film_actor fa ON f.film_id = fa.film_id                    -- Join with 'film_actor' to link films to their actors
JOIN actor a ON fa.actor_id = a.actor_id                        -- Join with 'actor' table to get actor details
ORDER BY f.title, actor_name                                    -- Order the results alphabetically by film title, then actor name
LIMIT 20;                                                       -- Return only the first 20 results
```

Query 2:

```sql
-- Select film titles and a comma-separated list of all actors in each film
SELECT
    f.title,                                                              -- Get the film's title from the 'film' table
    STRING_AGG(a.first_name || ' ' || a.last_name, ', ') AS actor_names  -- Combine all actor full names into one comma-separated string
FROM
    film f                                                                -- From the 'film' table aliased as 'f'
JOIN film_actor fa ON f.film_id = fa.film_id                              -- Join with 'film_actor' to link each film to its actors
JOIN actor a ON fa.actor_id = a.actor_id                                  -- Join with 'actor' table to get actor names
GROUP BY f.title                                                           -- Group results by film title so each row is one film
ORDER BY f.title                                                           -- Sort the results alphabetically by film title
LIMIT 20;                                                                  -- Return only the first 10 films
```

