const {
  onDocumentCreated,
  onDocumentUpdated,
} = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

// Envía una notificación push a todos los administradores
// (menos al usuario que originó el registro).
async function notifyAdmins(triggerUid, mensaje) {
  const db = getFirestore();

  const [userDoc, adminDocs] = await Promise.all([
    db.collection('usuarios').doc(triggerUid).get(),
    db.collection('usuarios').where('role', '==', 'admin').get(),
  ]);

  const userData = userDoc.data() || {};
  const nombre = userData.nombre || userData.username || 'un usuario';

  const tokens = [];
  adminDocs.forEach((doc) => {
    if (doc.id === triggerUid) return;
    const token = doc.data().fcmToken;
    if (token) tokens.push(token);
  });

  if (tokens.length === 0) return;

  await getMessaging().sendEachForMulticast({
    tokens,
    notification: {
      title: 'Pray IAFCJ',
      body: `${mensaje} de ${nombre}`,
    },
  });
}

exports.notifyAdminOnNewPrayer = onDocumentCreated(
  'usuarios/{uid}/oraciones/{id}',
  async (event) => {
    const data = event.data?.data() || {};
    const tiempo = data.tiempoOracion || '';
    await notifyAdmins(event.params.uid, `Nuevo registro de oraci\u00f3n${tiempo ? `: ${tiempo}` : ''}`);
  },
);

exports.notifyAdminOnNewReading = onDocumentCreated(
  'usuarios/{uid}/lecturas/{id}',
  async (event) => {
    const data = event.data?.data() || {};
    const cita = data.cita || '';
    await notifyAdmins(event.params.uid, `Nuevo registro de lectura${cita ? `: ${cita}` : ''}`);
  },
);

exports.notifyAdminOnUpdatedPrayer = onDocumentUpdated(
  'usuarios/{uid}/oraciones/{id}',
  async (event) => {
    const after = event.data?.after.data() || {};
    const tiempo = after.tiempoOracion || '';
    await notifyAdmins(event.params.uid, `Registro de oraci\u00f3n actualizado${tiempo ? `: ${tiempo}` : ''}`);
  },
);

exports.notifyAdminOnUpdatedReading = onDocumentUpdated(
  'usuarios/{uid}/lecturas/{id}',
  async (event) => {
    const after = event.data?.after.data() || {};
    const cita = after.cita || '';
    await notifyAdmins(event.params.uid, `Registro de lectura actualizado${cita ? `: ${cita}` : ''}`);
  },
);
