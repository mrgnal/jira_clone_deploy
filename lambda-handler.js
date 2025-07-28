const { SSMClient, GetParameterCommand } = require('@aws-sdk/client-ssm');
const { execSync } = require('child_process');

async function getDatabaseUrl(paramName) {
  const client = new SSMClient({});
  const command = new GetParameterCommand({
    Name: paramName,
    WithDecryption: true,
  });

  const response = await client.send(command);
  return response.Parameter.Value;
}

exports.migrate = async () => {
  try {
    const paramName = process.env.PARAM_NAME;

    if (!paramName) {
      throw new Error('PARAM_NAME is not defined in environment variables.');
    }

    console.log(`Fetching DATABASE_URL from SSM parameter: ${paramName}`);
    const databaseUrl = await getDatabaseUrl(paramName);
    process.env.DATABASE_URL = databaseUrl;

    console.log('Running `prisma migrate deploy`...');
    execSync('npx prisma migrate deploy', { stdio: 'inherit' });

    console.log('Running `prisma db seed`...');
    execSync('npx prisma db seed', { stdio: 'inherit' });

    console.log('Migration and seed completed successfully.');
    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'Migration and seed completed.' }),
    };
  } catch (error) {
    console.error('Error during migration or seed:');
    console.error(error.message || error);
    throw new Error('Migration or seed failed: ' + error.message);
  }
};
