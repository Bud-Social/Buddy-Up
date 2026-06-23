from channels.generic.websocket import AsyncJsonWebsocketConsumer


class UserConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        self.user_id = self.scope['url_route']['kwargs']['user_id']
        self.group_name = f'user_{self.user_id}'
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive_json(self, content, **kwargs):
        pass

    async def event_notification(self, event):
        await self.send_json(event['data'])

    async def event_message(self, event):
        await self.send_json(event['data'])

    async def event_presence(self, event):
        await self.send_json(event['data'])


class ConversationConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        self.conversation_id = self.scope['url_route']['kwargs']['conversation_id']
        self.group_name = f'conversation_{self.conversation_id}'
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive_json(self, content, **kwargs):
        await self.channel_layer.group_send(self.group_name, {
            'type': 'chat_message',
            'data': content,
        })

    async def chat_message(self, event):
        await self.send_json(event['data'])


class TypingConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        self.conversation_id = self.scope['url_route']['kwargs']['conversation_id']
        self.group_name = f'typing_{self.conversation_id}'
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive_json(self, content, **kwargs):
        await self.channel_layer.group_send(self.group_name, {
            'type': 'typing_event',
            'data': content,
        })

    async def typing_event(self, event):
        await self.send_json(event['data'])


class LiveConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        self.live_id = self.scope['url_route']['kwargs']['live_id']
        self.group_name = f'live_{self.live_id}'
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive_json(self, content, **kwargs):
        event_type = content.get('type', 'chat')
        await self.channel_layer.group_send(self.group_name, {
            'type': f'live_{event_type}',
            'data': content,
        })

    async def live_chat(self, event):
        await self.send_json(event['data'])

    async def live_reaction(self, event):
        await self.send_json(event['data'])

    async def live_viewer_count(self, event):
        await self.send_json(event['data'])

    async def live_gift(self, event):
        await self.send_json(event['data'])

    async def live_rep_counter(self, event):
        await self.send_json(event['data'])


class GymChatConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        self.gym_id = self.scope['url_route']['kwargs']['gym_id']
        self.group_name = f'gym_chat_{self.gym_id}'
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive_json(self, content, **kwargs):
        await self.channel_layer.group_send(self.group_name, {
            'type': 'gym_message',
            'data': content,
        })

    async def gym_message(self, event):
        await self.send_json(event['data'])


class RandomDropConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        self.group_name = 'random_drop_pool'
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive_json(self, content, **kwargs):
        event_type = content.get('type', 'join_pool')
        await self.channel_layer.group_send(self.group_name, {
            'type': f'random_drop_{event_type}',
            'data': content,
        })

    async def random_drop_join_pool(self, event):
        await self.send_json(event['data'])

    async def random_drop_match_found(self, event):
        await self.send_json(event['data'])
