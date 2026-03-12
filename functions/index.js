const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.getAllAuthUsers = functions.https.onCall(async (data, context) => {
  try {
    console.log('🚀 Fetching all auth users...');
    
    // List all users, page by page
    const listAllUsers = async (nextPageToken) => {
      const result = await admin.auth().listUsers(1000, nextPageToken);
      
      // Map users to safe format with all phone details
      const users = result.users.map((user) => {
        // Get provider data to find phone sign-in info
        const phoneProvider = user.providerData.find(
          (provider) => provider.providerId === 'phone'
        );
        
        // Convert timestamps to ISO strings to avoid Int64 issues
        const creationTime = user.metadata.creationTime 
          ? new Date(user.metadata.creationTime).toISOString() 
          : null;
        const lastSignInTime = user.metadata.lastSignInTime 
          ? new Date(user.metadata.lastSignInTime).toISOString() 
          : null;
        
        return {
          uid: user.uid,
          email: user.email || null,
          phoneNumber: user.phoneNumber || (phoneProvider ? phoneProvider.phoneNumber : null),
          displayName: user.displayName || user.phoneNumber || 'No name',
          photoURL: user.photoURL || null,
          // Send timestamps as ISO strings, not as Date objects
          creationTime: creationTime,
          lastSignInTime: lastSignInTime,
          // Provider specific info
          providerId: user.providerData.map((p) => p.providerId).join(', '),
          isPhoneUser: user.providerData.some((p) => p.providerId === 'phone'),
          // Raw provider data for debugging
          providers: user.providerData.map((p) => ({
            providerId: p.providerId,
            phoneNumber: p.phoneNumber,
            email: p.email,
            displayName: p.displayName,
          })),
        };
      });
      
      console.log(`📦 Fetched ${users.length} users in this batch`);
      
      if (result.pageToken) {
        // If there are more users, fetch next batch
        const nextUsers = await listAllUsers(result.pageToken);
        return [...users, ...nextUsers];
      }
      
      return users;
    };
    
    const allUsers = await listAllUsers();
    console.log(`✅ Total users fetched: ${allUsers.length}`);
    
    // Log phone users specifically
    const phoneUsers = allUsers.filter((u) => u.isPhoneUser);
    console.log(`📱 Phone users found: ${phoneUsers.length}`);
    phoneUsers.forEach((u, i) => {
      console.log(`   ${i+1}. ${u.phoneNumber} - ${u.displayName || 'No name'}`);
    });
    
    return allUsers;
    
  } catch (error) {
    console.error('❌ Error listing users:', error);
    throw new functions.https.HttpsError(
      'internal', 
      `Unable to list users: ${error.message}`
    );
  }
});