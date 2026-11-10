import { Client } from '@stomp/stompjs';
export function createGameSocket(): Client {
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
  return new Client({ brokerURL: `${protocol}//${window.location.host}/ws`, reconnectDelay: 3000 });
}
