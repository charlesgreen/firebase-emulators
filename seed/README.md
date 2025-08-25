# Firebase Emulators Seed Data

This directory contains seed data for the Firebase emulators to help you get started with development and testing.

## Available Seed Data

### Authentication (`auth.json`)
- **john.doe@example.com** - Regular user account
- **jane.smith@example.com** - Regular user account  
- **admin@example.com** - Admin user with elevated permissions

All seed users have the password: `password123`

### Firestore (`firestore.json`)
- **users** collection - User profile data
- **posts** collection - Sample blog posts with different states (published/draft)
- **comments** collection - Comments on posts
- **public** collection - Public configuration and statistics
- **admin** collection - Admin-only settings

## Using Seed Data

### With Docker Compose

Set environment variables in your `.env` file or docker-compose.yml:

```yaml
environment:
  - SEED_DATA=true
  - SEED_AUTH=true
  - SEED_FIRESTORE=true
```

### Manual Import

Use the admin tools to import seed data:

```bash
# Start the admin container
docker-compose --profile admin up firebase-admin

# Or use the admin tools directly
docker exec firebase-emulators ./scripts/admin-tools.sh import
```

### Custom Seed Data

Replace the JSON files in this directory with your own seed data:

1. **auth.json** - Follow the Firebase Auth export format
2. **firestore.json** - Use a nested JSON structure representing your Firestore collections

## Seed Data Structure

### Auth Users Format
```json
{
  "users": [
    {
      "localId": "unique-user-id",
      "email": "user@example.com",
      "emailVerified": true,
      "displayName": "User Name",
      "customClaims": "{\"role\":\"user\"}"
    }
  ]
}
```

### Firestore Collections Format
```json
{
  "collection-name": {
    "document-id": {
      "field1": "value1",
      "field2": "value2",
      "nestedObject": {
        "nestedField": "nestedValue"
      }
    }
  }
}
```

## Testing Credentials

### Regular Users
- **Email:** john.doe@example.com
- **Password:** password123
- **Claims:** `{"role": "user"}`

- **Email:** jane.smith@example.com  
- **Password:** password123
- **Claims:** `{"role": "user"}`

### Admin User
- **Email:** admin@example.com
- **Password:** password123
- **Claims:** `{"role": "admin", "admin": true}`

## Security Rules Testing

The seed data is designed to work with the example security rules in `/config`:

- Regular users can read/write their own data in `/users/{userId}`
- All users can read from `/public` collections
- Only admin users can access `/admin` collections
- Posts follow author-based permissions

## Customization

To customize the seed data for your project:

1. Update the JSON files with your data structure
2. Modify the security rules in `/config/firestore.rules`
3. Update the import logic in `/scripts/start-emulators.sh` if needed
4. Test with different user roles and permissions

## Backup and Restore

Use the admin tools to create backups of your emulator data:

```bash
# Create backup
docker exec firebase-emulators ./scripts/admin-tools.sh backup my-test-data

# Restore backup
docker exec firebase-emulators ./scripts/admin-tools.sh restore my-test-data
```