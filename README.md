# Waymark FHIR

A Phoenix application for integrating with FHIR (Fast Healthcare Interoperability Resources) to manage healthcare data.

## Environment Setup

1. Create a `.env` file in the `waymark_fhir` directory:
```bash
# Navigate to the project directory
cd waymark_fhir

# Create .env file
touch .env
```

2. Add the following content to .env:
```bash
# Database Configuration
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=localhost
POSTGRES_DB_TEST=waymark_fhir_test
POSTGRES_DB_DEV=waymark_fhir_dev
POSTGRES_POOL_SIZE=10

# RabbitMQ Configuration
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USERNAME=app_user
RABBITMQ_PASSWORD=rabbitmq
RABBITMQ_VHOST=/homework
RABBITMQ_QUEUE_TEST=fhir-inbound-test
RABBITMQ_QUEUE_DEV=fhir-inbound
RABBITMQ_URL=amqp://app_user:rabbitmq@localhost:5672/homework

# Phoenix Configuration
SECRET_KEY_BASE=<generated-secret>
PORT=4000
```

3. Generate and set the secret key:
```bash
# Make sure you're in the waymark_fhir directory
cd waymark_fhir
export SECRET_KEY_BASE=$(mix phx.gen.secret)
```

## Prerequisites

- Elixir 1.15.7
- Erlang/OTP 26
- PostgreSQL
- RabbitMQ
- Docker and Docker Compose

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/emmadevmorgan/waymark-care.git
   cd waymark_fhir
   ```

2. Install dependencies:
   ```bash
   mix deps.get
   ```

3. Create and migrate the database:
   ```bash
   mix ecto.create
   mix ecto.migrate
   ```

4. Start the required services using task in the root directory:
   ```bash
   task init
   ```
   This will start:
   - PostgreSQL database
   - RabbitMQ server
   - RabbitMQ management interface

5. Start the Phoenix server:
   ```bash
   mix phx.server
   ```
6. Visit http://localhost:4000/

## Testing

### Running Tests

The application uses a comprehensive test suite that includes:

1. Unit Tests:
   ```bash
   mix test
   ```

2. Specific Test Files:
   ```bash
   # Test FHIR transformer
   mix test test/waymark_fhir/fhir/transformer_test.exs
   
   # Test messaging consumer
   mix test test/waymark_fhir/messaging/consumer_test.exs
   
   # Test web interface
   mix test test/waymark_fhir_web/
   ```

### Test Coverage

The test suite includes:

1. **FHIR Transformer Tests**
   - Resource type validation
   - Data transformation accuracy
   - Error handling for invalid resources

2. **Messaging Tests**
   - RabbitMQ connection handling
   - Message processing
   - Error recovery
   - Mock implementation for testing

3. **Web Interface Tests**
   - Route handling
   - LiveView updates
   - Error pages
   - Flash messages

## Implementation Approach

### System Architecture

#### Message Queue (RabbitMQ)
- Dedicated vhost for isolation
- Separate credentials for admin and application
- Durable queues for message persistence
- Error handling and reconnection logic

#### Database (PostgreSQL)
- Ecto schemas for data modeling
- Migrations for schema versioning
- Associations for data relationships
- Indexes for performance optimization

#### Web Framework (Phoenix)
- LiveView for real-time updates
- Tailwind CSS for styling
- Error handling middleware
- Flash messages for user feedback

## Troubleshooting

### Common Issues

1. **Secret Key Base Missing**
   ```bash
   export SECRET_KEY_BASE=$(mix phx.gen.secret)
   ```

2. **RabbitMQ Connection Issues**
   - Check RabbitMQ is running: `docker-compose ps`
   - Verify credentials in `.env`
   - Check vhost exists: `rabbitmqctl list_vhosts`

3. **Database Connection Issues**
   - Check PostgreSQL is running: `docker-compose ps`
   - Verify database exists: `mix ecto.create`
   - Check migrations: `mix ecto.migrate`

4. **Test Failures**
   - Reset test database: `mix ecto.reset`
   - Check test configuration in `config/test.exs`
   - Verify test environment variables

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Phoenix Framework
- FHIR Standards
- RabbitMQ
- PostgreSQL

## Assessment Overview

### Project Goals
The assessment focused on building a robust FHIR integration system that:
1. Processes healthcare data through RabbitMQ
2. Transforms FHIR resources into application-specific schemas
3. Stores data in PostgreSQL
4. Provides a web interface for data visualization

### Implementation Approach

#### 1. System Architecture
- **Message Queue**: RabbitMQ for reliable message processing
- **Database**: PostgreSQL for persistent storage
- **Web Framework**: Phoenix with LiveView for real-time updates
- **Containerization**: Docker for consistent deployment

#### 2. Key Components

##### FHIR Integration
- Implemented FHIR resource transformation for:
  - Organizations
  - Practitioners (Waymarkers)
  - Patients
  - Encounters
- Maintained FHIR compliance while adapting to application needs
- Used proper error handling and validation

##### Message Processing
- Implemented a reliable consumer for processing FHIR messages
- Added message acknowledgment for guaranteed delivery
- Included error handling and retry mechanisms
- Maintained message order and consistency

##### Data Storage
- Created optimized database schemas
- Implemented proper relationships between entities
- Added indexes for better query performance
- Included data validation and constraints

##### Web Interface
- Built a responsive LiveView interface
- Implemented real-time updates
- Added proper error handling and user feedback
- Included data visualization components

#### 3. Technical Decisions

##### Why RabbitMQ?
- Reliable message delivery
- Message persistence
- Easy monitoring and management
- Built-in clustering support

##### Why PostgreSQL?
- ACID compliance
- JSON support for FHIR data
- Strong relationship management
- Excellent performance

##### Why Phoenix LiveView?
- Real-time updates without JavaScript
- Server-side rendering
- Built-in security features
- Excellent developer experience

#### 4. Implementation Challenges

1. **Message Processing**
   - Challenge: Ensuring message order and delivery
   - Solution: Implemented proper acknowledgment and error handling

2. **Data Transformation**
   - Challenge: Mapping FHIR resources to application schemas
   - Solution: Created a flexible transformer module

3. **Real-time Updates**
   - Challenge: Keeping UI in sync with backend changes
   - Solution: Utilized Phoenix LiveView for automatic updates

4. **Error Handling**
   - Challenge: Managing various failure scenarios
   - Solution: Implemented comprehensive error handling at each layer

#### 5. Testing Strategy

1. **Unit Tests**
   - Transformer logic
   - Schema validations
   - Query functions

2. **Integration Tests**
   - Message processing
   - Database operations
   - Web interface

3. **End-to-End Tests**
   - Complete workflow testing
   - Error scenario testing
   - Performance testing

#### 6. Future Improvements

1. **Scalability**
   - Add message partitioning
   - Implement caching
   - Add load balancing

2. **Monitoring**
   - Add detailed metrics
   - Implement tracing
   - Add performance monitoring

3. **Features**
   - Add search functionality
   - Implement filtering
   - Add export capabilities

### Conclusion

The assessment successfully delivered a robust FHIR integration system that:
- Processes healthcare data reliably
- Maintains data consistency
- Provides real-time updates
- Scales well with increasing load
- Is easy to maintain and extend

The implementation follows best practices for:
- Code organization
- Error handling
- Testing
- Documentation
- Deployment
