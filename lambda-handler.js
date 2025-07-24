const { execSync } = require('child_process');

exports.migrate = async () => {
  try {
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
