import { useParams } from 'react-router-dom';
export function RoomPage() { const { roomId } = useParams(); return <section><h1>대기실</h1><p>방 ID: {roomId}</p><p>참가자 목록/준비 상태 구현 예정</p></section>; }
